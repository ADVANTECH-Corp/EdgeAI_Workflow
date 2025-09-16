cmake_minimum_required(VERSION 3.10)
project(yolov8-object)

#   Force static builds
set(BUILD_SHARED_LIBS ON)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

#   Paths to dependencies
set(ONNXRUNTIME_DIR_INCLUDE "C:/temp/Microsoft.ML.OnnxRuntime.DirectML.1.18.0/build/native/include")
set(ONNXRUNTIME_DIR_LIB "C:/temp/Microsoft.ML.OnnxRuntime.DirectML.1.18.0/runtimes/win-x64/native")

set(OpenCV_DIR_INCLUDE "C:/temp/opencv/include")
set(OpenCV_DIR_LIB "C:/temp/opencv/staticlib")

set(gFLAG_DIR_INCLUDE "C:/temp/gflag/include")
set(gFLAG_DIR_LIB "C:/temp/gflag/lib")

#   Libraries (prebuilt .lib files)
set(lib_files
    gflags_static.lib
    onnxruntime.lib
    opencv_world470.lib
)

#   Your source files
set(src_files
    yolov8-object.cpp
)

#   Includes & library search paths
include_directories(
    ${ONNXRUNTIME_DIR_INCLUDE}
    ${OpenCV_DIR_INCLUDE}
    ${gFLAG_DIR_INCLUDE}
)

link_directories(
    ${ONNXRUNTIME_DIR_LIB}
    ${OpenCV_DIR_LIB}
    ${gFLAG_DIR_LIB}
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#   Build exe
add_executable(${PROJECT_NAME} ${src_files})

#   Link exe with libs
target_link_libraries(${PROJECT_NAME} PRIVATE ${lib_files})
