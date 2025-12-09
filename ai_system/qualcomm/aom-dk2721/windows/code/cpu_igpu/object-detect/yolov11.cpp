#define NOMINMAX
#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <chrono>
#include <opencv2/opencv.hpp>
#include <onnxruntime_cxx_api.h>
#include <dml_provider_factory.h>
#include <gflags/gflags.h>
#include "onnxruntime_session_options_config_keys.h" 
#include <unordered_map> 
#include <windows.h> 
using namespace std;
using namespace cv;
using namespace Ort;


 
DEFINE_string(model, "default.onnx", "Path to the ONNX model");
DEFINE_string(input, "", "Path to the input image/video");
DEFINE_string(device, "cpu", "Device to run on (cpu/gpu/npu)"); 

constexpr float NMS_THRESHOLD    = 0.45f;
int MODEL_INPUT_IMAGE_WIDTH     = 640;
int MODEL_INPUT_IMAGE_HEIGHT    = 640;
int MODEL_INPUT_INPUT_CHANNELS  = 3;



struct Object {
    cv::Rect bbox;
    int label = -1;
    float confidence = -1.f;
};


float calcIOU(const cv::Rect &a, const cv::Rect &b)
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

std::vector<Object> nms(std::vector<Object> win_list, const float &nms_thres)
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

 
/////////////////////////////////////////////////////////////////////////////////////


vector<string> load_labels(const string& filename) {
    vector<string> labels;
    ifstream file(filename);
    if (!file.is_open()) {
        cerr << "Failed to open label file: " << filename << endl;
        return labels;
    }
    string line;
    while (getline(file, line)) {
        labels.push_back(line);
    }
    return labels;
}

vector<float> preprocess(const Mat& frame) {
    Mat resized, rgb, float_img;
    resize(frame, resized, Size(MODEL_INPUT_IMAGE_WIDTH, MODEL_INPUT_IMAGE_HEIGHT));
    cvtColor(resized, rgb, COLOR_BGR2RGB);
    rgb.convertTo(float_img, CV_32F, 1.0 / 255.0);

    vector<float> tensor(MODEL_INPUT_INPUT_CHANNELS * MODEL_INPUT_IMAGE_HEIGHT * MODEL_INPUT_IMAGE_WIDTH);
    size_t idx = 0;
    for (int c = 0; c < MODEL_INPUT_INPUT_CHANNELS; ++c) {
        for (int y = 0; y < MODEL_INPUT_IMAGE_HEIGHT; ++y) {
            for (int x = 0; x < MODEL_INPUT_IMAGE_WIDTH; ++x) {
                tensor[idx++] = float_img.at<Vec3f>(y, x)[c];
            }
        }
    }
    return tensor;
}

 
void postprocess_2_test(float* output, int signalResultNum, int strideNum, 
                        float rectConfidenceThreshold, float nmsThreshold, // <-- NMS 門檻
                        float resizeScales_w, float resizeScales_h, 
                        const vector<string>& labels, Mat& frame)
{
    cv::Mat rawData;
    rawData = cv::Mat(signalResultNum, strideNum, CV_32F, output);
    rawData = rawData.t(); // Transpose to [8400, N]

    float* data = (float*)rawData.data;
    // 1. Store all candidate boxes
    std::vector<Object> proposals;
    proposals.reserve(strideNum); 

    for (int i = 0; i < strideNum; ++i)
    {
        float* classesScores = data + 4; 
        
        cv::Mat scores(1, static_cast<int>(labels.size()), CV_32FC1, classesScores); 

        cv::Point class_id_point;
        double maxClassScore;
        cv::minMaxLoc(scores, 0, &maxClassScore, 0, &class_id_point);
        
        if (maxClassScore > rectConfidenceThreshold)
        {
            float x = data[0];
            float y = data[1];
            float w = data[2];
            float h = data[3];

            int left = static_cast<int>((x - 0.5 * w) * resizeScales_w);
            int top = static_cast<int>((y - 0.5 * h) * resizeScales_h);
            int width = static_cast<int>(w * resizeScales_w);
            int height = static_cast<int>(h * resizeScales_h);
            
            proposals.push_back(Object{
                cv::Rect(left,top, width, height), // bbox
                class_id_point.x,                  // label
                (float)maxClassScore               // confidence
            });
        }
        data += signalResultNum;
    }

    // 2. Perform NMS
    std::vector<Object> kept = nms(std::move(proposals), nmsThreshold);

    // 3. Draw the results after NMS filtering
    for (const auto& o : kept)
    {
        cv::Rect bbox = o.bbox;
        int class_id = o.label;
        float conf = o.confidence;
        cv::rectangle(frame, bbox, cv::Scalar(0, 255, 0), 3); 

        std::string label = labels.empty() ? std::to_string(class_id) : labels[class_id];
        char text[128];
        
        if (labels.size() == 1) {
            //  std::snprintf(text, sizeof(text), "%s %.2f", labels[0].c_str(), conf);
            std::snprintf(text, sizeof(text), "%s", labels[0].c_str());
        } else {
            // std::snprintf(text, sizeof(text), "%s %.2f", label.c_str(), conf);
            std::snprintf(text, sizeof(text), "%s", label.c_str());
        }

        const float FONT_SCALE = 0.8f; 
        const int FONT_THICKNESS = 2;  

        int baseline = 0;
        cv::Size t = cv::getTextSize(text, cv::FONT_HERSHEY_SIMPLEX, FONT_SCALE, FONT_THICKNESS, &baseline);
        
        cv::Rect bg_rect = {
            bbox.x, 
            bbox.y - t.height - 10, 
            t.width + 10,             
            t.height + 10             
        };
        cv::rectangle(frame, bg_rect, cv::Scalar(0, 255, 0), -1);

        cv::Point text_pos = {
            bbox.x + 5,             
            bbox.y - 7              
        };
        cv::putText(frame, text, text_pos, cv::FONT_HERSHEY_SIMPLEX, FONT_SCALE, cv::Scalar(0, 0, 0), FONT_THICKNESS);
    }
}

std::wstring string_to_wstring(const std::string& str) {
     int size_needed = MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, nullptr, 0);
     std::wstring wstr(size_needed, 0);
     MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, &wstr[0], size_needed);
     return wstr;
}


int main(int argc, char* argv[]) {

    FLAGS_model  = "";
    FLAGS_input  = "";
    FLAGS_device = "CPU";

    gflags::ParseCommandLineFlags(&argc, &argv, true);

    std::cout << "Model  : " << FLAGS_model  << std::endl;
    std::cout << "Input  : " << FLAGS_input  << std::endl;
    std::cout << "Device : " << FLAGS_device << std::endl;
     
    string label_path = "coco.txt"; 

    std::wstring default_model_path = L"yolov8m.onnx";
    std::wstring selected_model_path;

    if (!FLAGS_model.empty()) {
        selected_model_path = string_to_wstring(FLAGS_model);
    }
    else {
        selected_model_path = default_model_path;
    }
    const wchar_t* model_path = selected_model_path.c_str(); 

    vector<string> labels = load_labels(label_path);
    if (labels.empty()) {
        std::cerr << "Labels file empty or missing. Using default 'face' label." << std::endl;
        labels.push_back("face"); 
    }

    Ort::Env env(ORT_LOGGING_LEVEL_WARNING, "YOLOv8");
    Ort::SessionOptions session_options;

    session_options.SetGraphOptimizationLevel(GraphOptimizationLevel::ORT_ENABLE_ALL);

    if (FLAGS_device=="GPU")
    {
        OrtStatus* statusML = OrtSessionOptionsAppendExecutionProvider_DML(session_options, 0);//default GPU 
        if (statusML != nullptr) {
            const char* msg = Ort::GetApi().GetErrorMessage(statusML);
            std::cerr << "Failed to add DirectML EP: " << msg << std::endl;
            Ort::GetApi().ReleaseStatus(statusML);
            exit(1);
        }
    }

    Ort::Session session(env, model_path, session_options);
    Ort::AllocatorWithDefaultOptions allocator;
    Ort::AllocatedStringPtr input_name_ptr = session.GetInputNameAllocated(0, allocator);
    const char* input_name = input_name_ptr.get();

    Ort::AllocatedStringPtr output_name_ptr = session.GetOutputNameAllocated(0, allocator);
    const char* output_name = output_name_ptr.get();
    
    vector<int64_t> input_shape = session.GetInputTypeInfo(0).GetTensorTypeAndShapeInfo().GetShape();

    MODEL_INPUT_INPUT_CHANNELS = static_cast<int>(input_shape[1]); //3
    MODEL_INPUT_IMAGE_HEIGHT   = static_cast<int>(input_shape[2]); //640
    MODEL_INPUT_IMAGE_WIDTH    = static_cast<int>(input_shape[3]); //640
    
    std::cout << "Input shape: [";
    for (auto d : input_shape) std::cout << d << " "; //NCHW : [1,3,640,640]
    std::cout << "]" << std::endl;

    auto output_info = session.GetOutputTypeInfo(0).GetTensorTypeAndShapeInfo();
    vector<int64_t> output_shape = output_info.GetShape();

    std::cout << "Output shape: [";
    for (auto d : output_shape) std::cout << d << " ";
    std::cout << "]" << std::endl;

    int num_attr  = static_cast<int>(output_shape[1]);
    int num_preds = static_cast<int>(output_shape[2]);
    
    if (labels.size() != (num_attr - 4)) {
        std::cerr << "[Warning] Model output attributes (" << num_attr << ") "
                  << "does not match label file count (" << labels.size() << ")." << std::endl;
        std::cerr << "If this is a face model (1 class + 10 landmarks), this is OK." << std::endl;
        
        if (num_attr == 84 && labels.size() == 1) {
            std::cerr << "Looks like COCO model but 'face' label. Re-loading 'coco.txt'" << std::endl;
            labels = load_labels("coco.txt");
            if (labels.size() != 80) {
                std::cerr << "Failed to load coco.txt. Exiting." << std::endl;
                return -1;
            }
        }
    }
    
    std::cout << "num_preds:  " << num_preds << std::endl;
    std::cout << "num_labels: " << labels.size() << std::endl;
 

    cv::VideoCapture cap;
    bool isVideoFile = false;

    try {
        int cam_index = std::stoi(FLAGS_input);
        cap.open(cam_index);
    }
    catch (...) {
        cap.open(FLAGS_input); 
        isVideoFile = true;     
    }
     

    if (!cap.isOpened()) {
        cerr << "Cannot open video or camera: " << FLAGS_input << endl;
        return -1;
    }

    Mat frame;
    chrono::steady_clock::time_point t1, t2;
    double fps = 0.0;

    float rectConfidenceThreshold = 0.3f;
    const std::string windowName = "Object-Detect"; 
    cv::namedWindow(windowName,  cv::WINDOW_KEEPRATIO);  // Allows window resizing  
    cv::resizeWindow(windowName, 1280, 720);  // Width x Height in pixels
    cout << "Press 'q' to quit." << endl;
    while (true) {

        t1 = chrono::steady_clock::now();
        bool success = cap.read(frame);
        if (!success || frame.empty()) {
            if (isVideoFile) {
                std::cout << "Video ended. Looping..." << std::endl;
                cap.release();
                cap.open(FLAGS_input);
                if (!cap.isOpened()) {
                    std::cerr << "Failed to re-open video. Exiting." << std::endl;
                    break;
                }
                cap.read(frame);
                if (frame.empty()) break; 
            } else {
                std::cout << "Camera feed lost. Exiting." << std::endl;
                break;
            }
        }

        vector<float> input_tensor = preprocess(frame); 
        Ort::MemoryInfo mem_info = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
        Ort::Value input_tensor_ort = Ort::Value::CreateTensor<float>(mem_info, input_tensor.data(), input_tensor.size(), input_shape.data(), input_shape.size());
        auto output_tensors = session.Run(Ort::RunOptions{ nullptr }, &input_name, &input_tensor_ort, 1, &output_name, 1);
        float* output_data = output_tensors.front().GetTensorMutableData<float>();
        float resizeScales_w = 0 , resizeScales_h =0;
        resizeScales_w = frame.cols / (float)MODEL_INPUT_IMAGE_WIDTH;
        resizeScales_h = frame.rows / (float)MODEL_INPUT_IMAGE_HEIGHT;
         
        postprocess_2_test(output_data, num_attr, num_preds, rectConfidenceThreshold, NMS_THRESHOLD, resizeScales_w, resizeScales_h, labels, frame);
 

        t2 = chrono::steady_clock::now();
        fps = 1000.0 / chrono::duration_cast<chrono::milliseconds>(t2 - t1).count();

        putText(frame, "FPS: " + to_string(int(fps)), Point(10, 30), FONT_HERSHEY_SIMPLEX, 1, Scalar(0, 255, 255), 2);

        double visible = cv::getWindowProperty(windowName, cv::WND_PROP_VISIBLE);
        double exists  = cv::getWindowProperty(windowName, cv::WND_PROP_AUTOSIZE); 
        if (visible < 1.0 || exists < 0) {
            std::cout << "Window closed by user." << std::endl;
            cv::destroyWindow(windowName);
            break;
        }
        cv::imshow(windowName, frame);
        int key = cv::waitKey(1); 
        if (key == 'q' || key == 27) {
             break;
        }
    }

    cap.release();
    cv::destroyAllWindows();
    return 0;
}