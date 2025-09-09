
////// kent,2025-08-15  add this file

#pragma once
#include <chrono>
#include <map>
#include <memory> 
#include <iostream>
#include <fstream> 

 #include <opencv2/opencv.hpp>


#include "fps_record.hpp"
#include "frame_info.hpp"
#include "global.hpp"
#include "queue.hpp"
#include "task.hpp"




struct CheckGuiTask : public AsyncTask { 
 public:
     CheckGuiTask() {}
  virtual ~CheckGuiTask() {}
  void init(const Config& config) override {
      return;
  }
  void run() override {  ////// kent,2025-08-15 
    auto propertyvalue = cv::getWindowProperty(GLOBAL_APP_NAME , cv::WND_PROP_VISIBLE); 
    if (propertyvalue != 1 && GLOBAL_IS_SHOW_IMAGE) {
       // std::ofstream outFile("getWindowProperty.txt"); // Create and open file 
       // outFile << propertyvalue;
       // outFile.close(); // Always close when done  
       g_stop();
    }  
      
  }

 
};