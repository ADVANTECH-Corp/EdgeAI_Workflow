// main.cpp
#include <iostream>
#include <string>
#include <vector>  
#include <sstream>    
#include <opencv2/opencv.hpp>
#include "ObjectDetector.hpp" 
#include <gflags/gflags.h>

// Define command-line arguments
DEFINE_string(model, "yolo_v5_quant.dlc", "Path to the SNPE .dlc model file");
DEFINE_string(input, "0", "Path to video file or camera ID (e.g., 0, 1)");
DEFINE_string(device, "DSP", "Runtime to use: CPU, GPU, or DSP");
DEFINE_string(labels, "coco.txt", "Path to the class labels file (e.g., coco.txt)");
DEFINE_double(conf, 0.25, "Confidence threshold for detection");
DEFINE_double(iou, 0.45, "NMS IoU threshold");
DEFINE_string(layer_names, "/model.24/m.0/Conv,/model.24/m.1/Conv,/model.24/m.2/Conv",
              "Comma-separated list of output layer names");
DEFINE_string(cls, "", "Comma-separated list of class names to detect (e.g., 'person,car'). Empty string means all classes.");


int main(int argc, char* argv[]) {
    gflags::ParseCommandLineFlags(&argc, &argv, true);
    std::cout << "Model:   " << FLAGS_model << std::endl;
    std::cout << "Input:   " << FLAGS_input << std::endl;
    std::cout << "Device:  " << FLAGS_device << std::endl;
    std::cout << "Labels:  " << FLAGS_labels << std::endl;
    std::cout << "Conf:    " << FLAGS_conf << std::endl;
    std::cout << "IoU:     " << FLAGS_iou << std::endl;
    std::cout << "Layers:  " << FLAGS_layer_names << std::endl;
    std::cout << "Classes: " << (FLAGS_cls.empty() ? "[All]" : FLAGS_cls.c_str()) << std::endl;

    std::vector<std::string> layer_names_vec;
    std::stringstream ss(FLAGS_layer_names);
    std::string layer;
    while (std::getline(ss, layer, ',')) {
        if (!layer.empty()) {
            layer_names_vec.push_back(layer);
        }
    }

    std::vector<std::string> allowed_classes_vec;
    if (!FLAGS_cls.empty()) {
        std::stringstream ss_classes(FLAGS_cls);
        std::string class_name;
        while (std::getline(ss_classes, class_name, ',')) {
            if (!class_name.empty()) {
                allowed_classes_vec.push_back(class_name);
            }
        }
    }

    // -----------------------------------------------------------------
    // 1. Initialize YOLO Detector
    // -----------------------------------------------------------------
    yolo::Detector engine;
        if (!engine.init(FLAGS_model, FLAGS_device, FLAGS_labels,
                     layer_names_vec, (float)FLAGS_conf, (float)FLAGS_iou,
                     allowed_classes_vec)) {
        std::cerr << "Failed to initialize SNPE Detector." << std::endl;
        return -1;
    }
    std::cout << "SNPE Detector initialized successfully." << std::endl;

    // -----------------------------------------------------------------
    // 2. Set video source
    // -----------------------------------------------------------------
    cv::VideoCapture cap;
    bool isVideoFile = false;

    try {
        int cam_index = std::stoi(FLAGS_input);
        cap.open(cam_index);
    }
    catch (const std::invalid_argument&) {
        cap.open(FLAGS_input);
        isVideoFile = true;
    }


    if (!cap.isOpened()) {
        std::cerr << "Cannot open video or camera: " << FLAGS_input << std::endl;
        return -1;
    }
    std::cout << "Video source opened. Starting capture loop..." << std::endl;

    const std::string windowName = "Object-Detect"; 
    cv::namedWindow(windowName,  cv::WINDOW_KEEPRATIO);  // Allows window resizing  
    cv::resizeWindow(windowName, 1280, 720);  // Width x Height in pixels
    
    // -----------------------------------------------------------------
    // 3. Main inference loop
    // -----------------------------------------------------------------
    cv::Mat frame;
    while (true) {
        cap.read(frame);
        if (frame.empty()) {
            if (isVideoFile) {
                std::cout << "Video ended. Looping..." << std::endl;
                cap.release();
                cap.open(FLAGS_input); 
                
                if (!cap.isOpened()) {
                    std::cerr << "Failed to re-open video file. Exiting." << std::endl;
                    break;
                }
                continue; 
            } else {
                std::cout << "Video ended or failed to grab frame." << std::endl;
                break; 
            }
        }
        
        if (!engine.detect(frame)) {
            std::cerr << "Detection failed on this frame." << std::endl;
        }
        
        cv::imshow(windowName, frame);
        
        int key = cv::waitKey(1); 

        if (cv::getWindowProperty(windowName, cv::WND_PROP_VISIBLE) < 1.0) {
            std::cout << "Window closed by user." << std::endl;
            break;
        }

        if (key == 'q' || key == 27) { // ESC
            break;
        }
    }

    cap.release();
    cv::destroyAllWindows();
    return 0;
}