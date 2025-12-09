/*
 * ===================================================================
 * ObjectDetector.cpp
 * ===================================================================
 */

#include "ObjectDetector.hpp"
#include "SNPEPipeline.hpp"

#include <algorithm>
#include <array>
#include <cmath>
#include <fstream>
#include <map>    
#include <numeric>
#include <tuple>
#include <chrono>
#include <set>      
#include <map>      


namespace {

// ====================== Utility Functions / Global State ======================
constexpr int kNumClasses = 80;
constexpr int kAnchorsPerCell = 3;
constexpr int kPerAnchor = 5 + kNumClasses;   // [x, y, w, h, obj, cls...]
constexpr int kChannels = kAnchorsPerCell * kPerAnchor;



inline float sigmoid(float x) { return 1.f / (1.f + std::exp(-x)); }

float g_scale = 1.f;
int g_padX = 0;
int g_padY = 0;
int g_origW = 0;
int g_origH = 0;

// Letterbox: keep aspect ratio while scaling, add gray padding
void letterbox(const cv::Mat& src, cv::Mat& dst, int newW, int newH,
               int& padX, int& padY, float& scale)
{
    const int sw = src.cols, sh = src.rows;
    float r = std::min(newW / (float)sw, newH / (float)sh);
    int w = (int)std::round(sw * r);
    int h = (int)std::round(sh * r);

    cv::Mat resized;
    cv::resize(src, resized, cv::Size(w, h));

    padX = (newW - w) / 2;
    padY = (newH - h) / 2;

    dst = cv::Mat(cv::Size(newW, newH), CV_8UC3, cv::Scalar(114, 114, 114));
    resized.copyTo(dst(cv::Rect(padX, padY, w, h)));
    scale = r;
}


// ====================== unletterbox ======================
inline cv::Rect unletterbox_xyxy(float x0, float y0, float x1, float y1)
{
    float X0 = (x0 - g_padX) / g_scale;
    float Y0 = (y0 - g_padY) / g_scale;
    float X1 = (x1 - g_padX) / g_scale;
    float Y1 = (y1 - g_padY) / g_scale;

    X0 = std::max(0.f, std::min(X0, (float)g_origW - 1));
    Y0 = std::max(0.f, std::min(Y0, (float)g_origH - 1));
    X1 = std::max(0.f, std::min(X1, (float)g_origW - 1));
    Y1 = std::max(0.f, std::min(Y1, (float)g_origH - 1));

    return cv::Rect(
        (int)X0,
        (int)Y0,
        (int)(X1 - X0),
        (int)(Y1 - Y0)
    );
}
} // namespace

// ====================== YOLO Detector ======================
namespace yolo {

bool Detector::init(const std::string &model_path, 
                    const std::string &device, 
                    const std::string &label_path,
                    const std::vector<std::string>& layer_names,
                    float conf_thresh,
                    float nms_thresh,
                    const std::vector<std::string>& allowed_classes)
{
    m_snpe_task = std::make_unique<snpe::SNPEPipeline>();
    
    if (!m_snpe_task->init(model_path, device, layer_names)) {
        std::cerr << "[Error] Failed to initialize SNPE.\n";
        return false;
    }

    if (!loadLabels(label_path)) {
        std::cerr << "[Error] Failed to load labels from " << label_path << "\n";
        return false;
    }
    std::cout << "[Detector] Loaded " << m_class_names.size() << " labels.\n";

    m_allowed_class_indices.clear();
    if (allowed_classes.empty()) {
        std::cout << "[Detector] No class filter specified. Detecting all classes.\n";
    } else {
        std::map<std::string, int> name_to_index;
        for (int i = 0; i < (int)m_class_names.size(); ++i) {
            name_to_index[m_class_names[i]] = i;
        }

        std::cout << "[Detector] Filtering for classes: ";
        for (const auto& name : allowed_classes) {
            if (name_to_index.count(name)) {
                int index = name_to_index[name];
                m_allowed_class_indices.insert(index);
                std::cout << "'" << name << "' (ID " << index << ") ";
            } else {
                std::cerr << "[Warning] Class '" << name << "' not found in labels file. Skipping.\n";
            }
        }
        std::cout << "\n";
    }

    m_confThresh = conf_thresh;
    m_nmsThresh = nms_thresh;
    std::cout << "[Detector] Conf threshold: " << m_confThresh << "\n";
    std::cout << "[Detector] NMS threshold: " << m_nmsThresh << "\n";
    // Get the input dimensions from SNPE
    int inC = 0;
    if (!m_snpe_task->getInputSize(m_inW, m_inH, inC)) {
        std::cerr << "[Detector][Error] Failed to get input size from SNPE\n";
        return false;
    }

    std::cout << "[Detector] Network input size: "
              << m_inW << " x " << m_inH << " x " << inC << "\n";

    m_isInit = m_snpe_task->isInit();
    m_frameCount = 0;
    return m_isInit;
}

bool Detector::loadLabels(const std::string& path)
{
    m_class_names.clear();
    std::ifstream file(path);
    if (!file.is_open()) return false;

    std::string line;
    while (std::getline(file, line)) {
        if (!line.empty() && line.back() == '\r') line.pop_back();
        if (!line.empty()) m_class_names.push_back(line);
    }
    return !m_class_names.empty();
}

// ===========================================================
// Preprocess：Letterbox + Normalize (0~1)
// ===========================================================
bool Detector::preprocess(cv::Mat &frame)
{
    g_origW = frame.cols;
    g_origH = frame.rows;

    cv::Mat lb;
    letterbox(frame, lb, m_inW, m_inH, g_padX, g_padY, g_scale);
    cv::cvtColor(lb, lb, cv::COLOR_BGR2RGB);

    cv::Mat lb_f;
    lb.convertTo(lb_f, CV_32FC3, 1.0 / 255.0);

    std::vector<float> input_vec;
    input_vec.reserve(m_inW * m_inH * 3);

    for (int y = 0; y < lb_f.rows; ++y) {
        const float* row = lb_f.ptr<float>(y);
        for (int x = 0; x < lb_f.cols * 3; ++x)
            input_vec.push_back(row[x]);
    }

    m_snpe_task->loadInputTensor(input_vec);
    return true;
}

// ===========================================================
// Main inference flow
// ===========================================================
bool Detector::detect(cv::Mat &frame)
{
    if (frame.empty()) return false;

    if (!preprocess(frame)) {
        std::cerr << "[Error] Preprocess failed.\n";
        return false;
    }

    auto t1 = std::chrono::steady_clock::now();
    if (!m_snpe_task->execute()) {
        std::cerr << "[Error] SNPE execute failed.\n";
        return false;
    }
    auto t2 = std::chrono::steady_clock::now();

    // Show FPS
    float fps = 1000.0f / std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count();
    cv::putText(frame, "FPS: " + std::to_string(int(fps)), {10, 35},
                cv::FONT_HERSHEY_SIMPLEX, 1, cv::Scalar(0, 255, 255), 2);

    if (!postprocess(frame)) {
        std::cerr << "[Error] Postprocess failed.\n";
        return false;
    }
    ++m_frameCount;
    return true;
}

// ===========================================================
// Postprocess: decoding + NMS + visualization drawing
// ===========================================================
bool Detector::postprocess(cv::Mat &frame)
{
    std::vector<snpe::OutputTensor> outputs;
    m_snpe_task->getOutputTensors(outputs);
    if (outputs.empty()) return false;

    std::vector<Object> proposals;
    proposals.reserve(2100);

    // Get the output tensor
    const auto &t = outputs[0];
    const auto &shape = t.shape; // Expect {1, 84, 2100}
    const auto &data = t.data;
    
    // Safety check for dimensions
    if (shape.size() < 3) {
        std::cerr << "[Error] Output shape invalid size: " << shape.size() << "\n";
        return false;
    }

    int channels = (int)shape[1]; // 84
    int anchors  = (int)shape[2]; // 2100

    if (channels < 5) return false; 

    for (int i = 0; i < anchors; ++i) {
        
        // 1. Find the best class score first (Optimization)
        float max_score = -10000.0f; // Init with low value
        int best_class_id = -1;

        // Loop through class channels (4 to 83)
        for (int c = 0; c < (channels - 4); ++c) {
            // Access logic: data[channel * anchors + index]
            float score = data[(4 + c) * anchors + i];
            if (score > max_score) {
                max_score = score;
                best_class_id = c;
            }
        }

        // 2. Threshold filter
        if (max_score < m_confThresh) continue;

        // Filter by allowed classes if set
        if (!m_allowed_class_indices.empty() &&
            m_allowed_class_indices.count(best_class_id) == 0) continue;

        // 3. Decode Box Coordinates
        float cx = data[0 * anchors + i];
        float cy = data[1 * anchors + i];
        float w  = data[2 * anchors + i];
        float h  = data[3 * anchors + i];

        float x0 = cx - w * 0.5f;
        float y0 = cy - h * 0.5f;
        float x1 = cx + w * 0.5f;
        float y1 = cy + h * 0.5f;

        // 4. Scale back to original image (Unletterbox)
        cv::Rect rect = unletterbox_xyxy(x0, y0, x1, y1);

        if (rect.width > 0 && rect.height > 0) {
            proposals.push_back(Object{rect, best_class_id, max_score});
        }
    }

    // NMS
    auto kept = nms(std::move(proposals), m_nmsThresh);

    // ========== Visualization (Same as before) ==========
    for (const auto& o : kept)
    {
        cv::rectangle(frame, o.bbox, cv::Scalar(0, 255, 0), 3);
        
        std::string cls_name = (o.label < (int)m_class_names.size()) ?
                               m_class_names[o.label] : std::to_string(o.label);

        char text[128];
        // std::snprintf(text, sizeof(text), "%s %.2f", cls_name.c_str(), o.confidence);
        std::snprintf(text, sizeof(text), "%s", cls_name.c_str());


        int baseline = 0;
        const float FONT_SCALE = 0.8f; 
        const int FONT_THICKNESS = 2;  
        cv::Size t = cv::getTextSize(text, cv::FONT_HERSHEY_SIMPLEX, FONT_SCALE, FONT_THICKNESS, &baseline);
        

        cv::Rect bg_rect = {
            o.bbox.x, 
            o.bbox.y - t.height - 10, 
            t.width + 10,            
            t.height + 10           
        };
        cv::rectangle(frame, bg_rect, cv::Scalar(0, 255, 0), -1);

        cv::Point text_pos = {
            o.bbox.x + 5,           
            o.bbox.y - 7             
        };
        cv::putText(frame, text, text_pos, cv::FONT_HERSHEY_SIMPLEX, FONT_SCALE, cv::Scalar(0, 0, 0), FONT_THICKNESS);
    }

    return true;
}
// ===========================================================
// NMS and IoU
// ===========================================================
std::vector<Object> Detector::nms(std::vector<Object> win_list, const float &nms_thres)
{
    if (win_list.empty()) return win_list;
    std::sort(win_list.begin(), win_list.end(),
              [](const Object& a, const Object& b) { return a.confidence > b.confidence; });

    std::vector<bool> removed(win_list.size(), false);
    std::vector<Object> keep;

    for (size_t i = 0; i < win_list.size(); ++i) {
        if (removed[i]) continue;
        keep.push_back(win_list[i]);
        for (size_t j = i + 1; j < win_list.size(); ++j) {
            if (removed[j]) continue;
            if (win_list[i].label != win_list[j].label) continue;
            if (calcIOU(win_list[i].bbox, win_list[j].bbox) > nms_thres)
                removed[j] = true;
        }
    }
    return keep;
}

float Detector::calcIOU(const cv::Rect &a, const cv::Rect &b)
{
    int interX1 = std::max(a.x, b.x);
    int interY1 = std::max(a.y, b.y);
    int interX2 = std::min(a.x + a.width, b.x + b.width);
    int interY2 = std::min(a.y + a.height, b.y + b.height);
    int interW = std::max(0, interX2 - interX1);
    int interH = std::max(0, interY2 - interY1);
    int interArea = interW * interH;
    int unionArea = a.area() + b.area() - interArea;
    return (unionArea > 0) ? (float)interArea / unionArea : 0.f;
}

} // namespace yolo