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


using namespace std;
using namespace cv;
using namespace Ort;
 
DEFINE_string(model, "default.onnx", "Path to the ONNX model");
DEFINE_string(input, "", "Path to the input image/video");
DEFINE_string(device, "cpu", "Device to run on (cpu/gpu)");
//DEFINE_string(label, "labels.txt", "labels for inference");

 

constexpr float CONF_THRESHOLD  = 0.4f; 
int MODEL_INPUT_IMAGE_WIDTH     = 640;//640
int MODEL_INPUT_IMAGE_HEIGHT    = 640;//640
int MODEL_INPUT_INPUT_CHANNELS  = 3;//3


//////////////////////////////////////////////////////////////////////////////////
void  PreProcess_test(cv::Mat& iImg, std::vector<int> iImgSize, cv::Mat& oImg)
{
    if (iImg.channels() == 3)
    {
        oImg = iImg.clone();
        cv::cvtColor(oImg, oImg, cv::COLOR_BGR2RGB);
    }
    else
    {
        cv::cvtColor(iImg, oImg, cv::COLOR_GRAY2RGB);
    }

   
    float resize_Scales = 0;
    if (iImg.cols >= iImg.rows)
    {
        resize_Scales = iImg.cols / (float)iImgSize.at(0);
        cv::resize(oImg, oImg, cv::Size(iImgSize.at(0), int(iImg.rows / resize_Scales)));
    }
    else
    {
        resize_Scales = iImg.rows / (float)iImgSize.at(0);
        cv::resize(oImg, oImg, cv::Size(int(iImg.cols / resize_Scales), iImgSize.at(1)));
    }
    cv::Mat tempImg = cv::Mat::zeros(iImgSize.at(0), iImgSize.at(1), CV_8UC3);
    oImg.copyTo(tempImg(cv::Rect(0, 0, oImg.cols, oImg.rows)));
    oImg = tempImg;
    
    
}

template<typename T>
void BlobFromImage(cv::Mat& iImg, T& iBlob) {
    int channels = iImg.channels();
    int imgHeight = iImg.rows;
    int imgWidth = iImg.cols;

    for (int c = 0; c < channels; c++)
    {
        for (int h = 0; h < imgHeight; h++)
        {
            for (int w = 0; w < imgWidth; w++)
            {
                iBlob[c * imgWidth * imgHeight + h * imgWidth + w] = typename std::remove_pointer<T>::type(
                    (iImg.at<cv::Vec3b>(h, w)[c]) / 255.0f);
            }
        }
    }
    //return RET_OK;
}
 
/////////////////////////////////////////////////////////////////////////////////////


// Load class labels from file
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

// Preprocess image to NCHW float32 tensor
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
 
  
 void postprocess_2_test(float* output, int signalResultNum, int strideNum, float rectConfidenceThreshold, float resizeScales_w,float resizeScales_h, const vector<string>& labels, Mat& frame)
 {

     // int signalResultNum = outputNodeDims[1]; //84
     // int strideNum       = outputNodeDims[2]; //8400
     //std::vector<int> class_ids;
     //std::vector<float> confidences;
     //std::vector<cv::Rect> boxes;
     cv::Mat rawData;
     //if (modelType == YOLO_DETECT_V8)
     //{
       // FP32

     rawData = cv::Mat(signalResultNum, strideNum, CV_32F, output);

     //}
     //else
     //{
         // FP16
        // rawData = cv::Mat(signalResultNum, strideNum, CV_16F, output);
        // rawData.convertTo(rawData, CV_32F);
     //}
     // Note:
     // ultralytics add transpose operator to the output of yolov8 model.which make yolov8/v5/v7 has same shape
     // https://github.com/ultralytics/assets/releases/download/v8.3.0/yolov8n.pt
     rawData = rawData.t();

     float* data = (float*)rawData.data;

     for (int i = 0; i < strideNum; ++i)
     {
         float* classesScores = data + 4;
         //cv::Mat scores(1, this->classes.size(), CV_32FC1, classesScores);
         cv::Mat scores(1, 80, CV_32FC1, classesScores);

         cv::Point class_id;
         double maxClassScore;
         cv::minMaxLoc(scores, 0, &maxClassScore, 0, &class_id);
         if (maxClassScore > rectConfidenceThreshold)
         {

             //confidences.push_back(maxClassScore);
             //class_ids.push_back(class_id.x);

             float x = data[0];
             float y = data[1];
             float w = data[2];
             float h = data[3];


             int left = int((x - 0.5 * w) * resizeScales_w);
             int top = int((y - 0.5 * h) * resizeScales_h);
             int width = int(w * resizeScales_w);
             int height = int(h * resizeScales_h);
  
             cv::Rect rt = cv::Rect(left,top, width, height);

             // Draw //////////////////////add 
             rectangle(frame, rt, Scalar(0, 255, 0), 2);
            
             string label = labels.empty() ? to_string(class_id.x) : labels[class_id.x];
             //string text = label + ": " + to_string(conf).substr(0, 4); 
             cv::putText(frame, label, Point(left, top - 10), FONT_HERSHEY_SIMPLEX, 0.5, Scalar(0, 255, 0), 1);


         }
         data += signalResultNum;
     }
 }

 std::wstring string_to_wstring(const std::string& str) {
     int size_needed = MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, nullptr, 0);
     std::wstring wstr(size_needed, 0);
     MultiByteToWideChar(CP_UTF8, 0, str.c_str(), -1, &wstr[0], size_needed);
     return wstr;
 }


int main(int argc, char* argv[]) {


    ///////////////////////////////////////////////////////////////
    FLAGS_model  = "";
    FLAGS_input  = "";
    FLAGS_device = "CPU";

    gflags::ParseCommandLineFlags(&argc, &argv, true);

    std::cout << "Model  : " << FLAGS_model  << std::endl;
    std::cout << "Input  : " << FLAGS_input  << std::endl;
    std::cout << "Device : " << FLAGS_device << std::endl;
    ///////////////////////////////////////////////////////////////
     
    string label_path = "coco.txt"; 
    std::wstring default_model_path = L"yolov8m.onnx";
    std::wstring selected_model_path;

    // Convert FLAGS_model if provided
    if (!FLAGS_model.empty()) {
        selected_model_path = string_to_wstring(FLAGS_model);
    }
    else {
        selected_model_path = default_model_path;
    }
    const wchar_t* model_path = selected_model_path.c_str(); 

    // Load labels
    vector<string> labels = load_labels(label_path);
    if (labels.empty()) {
        cerr << "Labels file empty or missing." << endl;
        return -1;
    }

    // Setup ONNX Runtime
    Ort::Env env(ORT_LOGGING_LEVEL_WARNING, "YOLOv8");
    Ort::SessionOptions session_options;
    session_options.SetGraphOptimizationLevel(GraphOptimizationLevel::ORT_ENABLE_ALL);
    
    //////////////////////support iGpu if not : support CPU
   
   
    if (FLAGS_device.compare("GPU") == 0)
    {
        OrtStatus* statusML = OrtSessionOptionsAppendExecutionProvider_DML(session_options, 0);//default GPU 
        if (statusML != nullptr) {
            const char* msg = Ort::GetApi().GetErrorMessage(statusML);
            std::cerr << "Failed to add DirectML EP: " << msg << std::endl;
            Ort::GetApi().ReleaseStatus(statusML);
            exit(1);
        }
    }

    /////////////////////////////////////////////////////////////////////////////////

    Ort::Session session(env, model_path, session_options);
    
    Ort::AllocatorWithDefaultOptions allocator;
    Ort::AllocatedStringPtr input_name_ptr = session.GetInputNameAllocated(0, allocator);
    const char* input_name = input_name_ptr.get();

    Ort::AllocatedStringPtr output_name_ptr = session.GetOutputNameAllocated(0, allocator);
    const char* output_name = output_name_ptr.get();
    
    vector<int64_t> input_shape = session.GetInputTypeInfo(0).GetTensorTypeAndShapeInfo().GetShape();

    MODEL_INPUT_INPUT_CHANNELS = input_shape[1]; //3
    MODEL_INPUT_IMAGE_HEIGHT   = input_shape[2]; //640
    MODEL_INPUT_IMAGE_WIDTH    = input_shape[3]; //640
    
    std::cout << "Input shape: [";
    for (auto d : input_shape) std::cout << d << " "; //NCHW : [1,3,640,640]
    std::cout << "]" << std::endl;

    //const char* output_name = session.GetOutputName(0, allocator);
    auto output_info = session.GetOutputTypeInfo(0).GetTensorTypeAndShapeInfo();
    vector<int64_t> output_shape = output_info.GetShape();

    // size_t output_tensor_size = 1;
    // for (auto dim : output_shape) output_tensor_size *= dim;

    std::cout << "Output shape: [";
    for (auto d : output_shape) std::cout << d << " ";
    std::cout << "]" << std::endl;


    int num_attr  = output_shape[1];  // 84  
    int num_preds = output_shape[2];  // 8400
   
    std::cout << "num_preds:  " << num_preds << std::endl;

 

    cv::VideoCapture cap;
    try {
        int cam_index = std::stoi(FLAGS_input);
        cap.open(cam_index);
        //cap.set(cv::CAP_PROP_FRAME_WIDTH, FLAGS_width);
        //cap.set(cv::CAP_PROP_FRAME_HEIGHT, FLAGS_height);
    }
    catch (...) {
        cap.open(FLAGS_input);  // Try as filename
    }
     

    if (!cap.isOpened()) {
        cerr << "Cannot open video or camera" << endl;
        return -1;
    }

    Mat frame;
    chrono::steady_clock::time_point t1, t2;
    double fps = 0.0;

    float rectConfidenceThreshold = 0.3;
     
    const std::string windowName = "YOLOv8-Object-Detect"; 
    //cv::namedWindow(windowName, cv::WINDOW_NORMAL | cv::WINDOW_KEEPRATIO);  // Allows window resizing  
    
    cv::namedWindow(windowName,  cv::WINDOW_KEEPRATIO);  // Allows window resizing  

    cv::resizeWindow(windowName, 1280, 720);  // Width x Height in pixels

    cout << "Press 'q' to quit." << endl;

    while (true) {

        t1 = chrono::steady_clock::now();

        bool success = cap.read(frame);

        if (!success)
        {
            cap.set(cv::CAP_PROP_POS_FRAMES,0);
            cap.read(frame);
        }

       // if (!cap.read(frame)) break;

        // Preprocess 
        vector<float> input_tensor = preprocess(frame); 
        // for (float val : input_tensor) {
        // cout << "input_tensor value: " << val << endl;}

        // Create input tensor
        Ort::MemoryInfo mem_info = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
        Ort::Value input_tensor_ort = Ort::Value::CreateTensor<float>(mem_info, input_tensor.data(), input_tensor.size(), input_shape.data(), input_shape.size());

        // Run inference
        auto output_tensors = session.Run(Ort::RunOptions{ nullptr }, &input_name, &input_tensor_ort, 1, &output_name, 1);

        float* output_data = output_tensors.front().GetTensorMutableData<float>();

        float resizeScales_w = 0 , resizeScales_h =0;

        resizeScales_w = frame.cols / (float)MODEL_INPUT_IMAGE_WIDTH;
        resizeScales_h = frame.rows / (float)MODEL_INPUT_IMAGE_HEIGHT;
         
        postprocess_2_test(output_data, num_attr, num_preds, rectConfidenceThreshold, resizeScales_w, resizeScales_h, labels, frame);
 

        // Calculate FPS
        t2 = chrono::steady_clock::now();
        fps = 1000.0 / chrono::duration_cast<chrono::milliseconds>(t2 - t1).count();

        putText(frame, "FPS: " + to_string(int(fps)), Point(10, 30), FONT_HERSHEY_SIMPLEX, 1, Scalar(0, 255, 255), 2);
         
        // Step 3: Show the image
        cv::imshow(windowName, frame);
        
     
        if (cv::getWindowProperty(windowName, cv::WND_PROP_AUTOSIZE) == 1  ) { 
             break; // in opencv 4.7 is ok for win11
        }

         
        int key = cv::waitKey(1); 
        if (key == 'q' || key == 27) {
                break;
        }


    }
    //cv::destroyAllWindows();  // Closes all OpenCV windows
    cap.release();
    cv::destroyAllWindows();
    return 0;
}
 