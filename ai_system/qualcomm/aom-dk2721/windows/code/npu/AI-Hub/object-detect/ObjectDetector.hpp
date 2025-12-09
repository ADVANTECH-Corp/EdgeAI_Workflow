// ObjectDetector.hpp
#ifndef OBJECT_DETECTOR_HPP_
#define OBJECT_DETECTOR_HPP_

#include <string>
#include <vector>
#include <iostream>
#include <fstream>
#include <set>                 
#include "SNPEPipeline.hpp"
#include "opencv2/opencv.hpp"

namespace yolo {

struct Object {
    cv::Rect bbox;
    int label = -1;
    float confidence = -1.f;
};

class Detector {
public:
    Detector() {} 
    bool init(const std::string &model_path, 
              const std::string &device, 
              const std::string &label_path,
              const std::vector<std::string>& layer_names,
              float conf_thresh,
              float nms_thresh,
              const std::vector<std::string>& allowed_classes); 
    bool isInit() { return m_isInit; }
    bool detect(cv::Mat &frame);

private:
    bool m_isInit = false;
    std::unique_ptr<snpe::SNPEPipeline> m_snpe_task;
    int m_frameCount = 0; 
    int m_inW = 0;
    int m_inH = 0;
    
    std::vector<std::string> m_class_names;
    bool loadLabels(const std::string& path);
    
    float m_confThresh;
    float m_nmsThresh;
    std::set<int> m_allowed_class_indices;


    bool preprocess(cv::Mat &frame);
    bool postprocess(cv::Mat &frame);

    std::vector<Object> nms(std::vector<Object> win_lis, const float &nms_thres);
    float calcIOU(const cv::Rect &a, const cv::Rect &b);
};

} // namespace yolo
#endif // OBJECT_DETECTOR_HPP_