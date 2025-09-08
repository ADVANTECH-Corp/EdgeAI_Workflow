cmake_minimum_required(VERSION 3.10)
project(yolov8-object)

############################                Change this!              #####################################################
# Path to ONNX Runtime include and lib  
 
set(ONNXRUNTIME_DIR_INCLUDE "C:/Users/AIMB-2210/Desktop/dev/DirectML/Microsoft.ML.OnnxRuntime.DirectML.1.18.0/build/native/include")  
set(ONNXRUNTIME_DIR_LIB "C:/Users/AIMB-2210/Desktop/dev/DirectML/Microsoft.ML.OnnxRuntime.DirectML.1.18.0/runtimes/win-x64/native")  

set(OpenCV_DIR_INCLUDE "C:/Users/AIMB-2210/Desktop/dev/DirectML/opencv-470/build/include")
set(OpenCV_DIR_LIB "C:/Users/AIMB-2210/Desktop/dev/DirectML/opencv-470/build/x64/vc16/lib")  

set(gFLAG_DIR_INCLUDE "C:/Users/AIMB-2210/Desktop/dev/DirectML/gflags.2.1.2.1/build/native/include")
set(gFLAG_DIR_LIB "C:/Users/AIMB-2210/Desktop/dev/DirectML/gflags.2.1.2.1/build/native/x64/v120/dynamic/Lib")  



############################################################################################################################


set(lib_files gflags.lib onnxruntime.lib opencv_world470.lib)
set(src_files yolov8-object.cpp)

# Include and link
include_directories(${ONNXRUNTIME_DIR_INCLUDE} ${OpenCV_DIR_INCLUDE} ${gFLAG_DIR_INCLUDE})
link_directories(${ONNXRUNTIME_DIR_LIB} ${OpenCV_DIR_LIB} ${gFLAG_DIR_LIB})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add executable
add_executable(${PROJECT_NAME} ${src_files})

target_link_libraries(${PROJECT_NAME} ${lib_files})

