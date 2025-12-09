cmake_minimum_required(VERSION 3.10)
project(yolov11-object-cpu-igpu)


# --- OpenCV ---
set(OpenCV_DIR_INCLUDE "C:\\Temp\\aisdk\\opencv\\include")
set(OpenCV_DIR_LIB     "C:\\Temp\\aisdk\\opencv\\ARM64/vc17\\lib")

# --- gflags ---
set(gFLAG_DIR_INCLUDE "C:\\Temp\\aisdk\\gflags\\mybuild\\build\\include")
set(gFLAG_DIR_LIB     "C:\\Temp\\aisdk\\gflags\\mybuild\\build\\lib")

# --- ONNX Runtime  (ARM64 package) ---
set(ONNXRUNTIME_QNN_DIR_INCLUDE "C:\\Temp\\aisdk\\Microsoft.ML.OnnxRuntime.DirectML.1.18.0\\build\\native\\include")
set(ONNXRUNTIME_QNN_DIR_LIB     "C:\\Temp\\aisdk\\Microsoft.ML.OnnxRuntime.DirectML.1.18.0\\runtimes\\win-arm64\\native")



# --- Source files ---
set(src_files yolov11.cpp)

set(_opencv_modules
  core imgproc highgui imgcodecs videoio calib3d features2d photo flann ml stitching video
)
set(OPENCV_LIBS "")
foreach(m IN LISTS _opencv_modules)
  file(GLOB _one "${OpenCV_DIR_LIB}/opencv_${m}*.lib")
  list(APPEND OPENCV_LIBS ${_one})
endforeach()

###########################################################################

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Fix C4819: use UTF-8 source code page (also recommended to save .cpp as UTF-8)
if(MSVC)
  add_compile_options(/source-charset:utf-8)
endif()

add_executable(${PROJECT_NAME} ${src_files})

# include / lib paths
target_include_directories(${PROJECT_NAME} PRIVATE
  "${OpenCV_DIR_INCLUDE}"
  "${gFLAG_DIR_INCLUDE}"
  "${ONNXRUNTIME_QNN_DIR_INCLUDE}"
)
target_link_directories(${PROJECT_NAME} PRIVATE
  "${OpenCV_DIR_LIB}"
  "${gFLAG_DIR_LIB}"
  "${ONNXRUNTIME_QNN_DIR_LIB}"
)

target_link_libraries(${PROJECT_NAME} PRIVATE
  gflags
  onnxruntime
  ${OPENCV_LIBS}
)

if(MSVC)
  set_property(TARGET ${PROJECT_NAME} PROPERTY
    MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
endif()

message(STATUS "OpenCV include: ${OpenCV_DIR_INCLUDE}")
message(STATUS "OpenCV lib dir: ${OpenCV_DIR_LIB}")
message(STATUS "Resolved OpenCV libs: ${OPENCV_LIBS}")
