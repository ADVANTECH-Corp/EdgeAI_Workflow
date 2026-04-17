cmake_minimum_required(VERSION 3.10)
project(yolov11-object)


set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


set(HOME_DIR $ENV{HOME})

# --- OpenCV ---
set(OpenCV_DIR_INCLUDE "${HOME_DIR}/aisdk/opencv/include" "${HOME_DIR}/aisdk/opencv/include/opencv4")
set(OpenCV_DIR_LIB     "${HOME_DIR}/aisdk/opencv/lib")

# --- gflags ---
set(gFLAG_DIR_INCLUDE "${HOME_DIR}/aisdk/gflags/include")
set(gFLAG_DIR_LIB     "${HOME_DIR}/aisdk/gflags/lib")

# --- SNPE SDK ---
set(SNPE_SDK_DIR "/opt/qcom/aistack/qairt/2.41.0.251128")
set(SNPE_PLATFORM_STR "aarch64-oe-linux-gcc11.2")
set(SNPE_LIB_DIR "${SNPE_SDK_DIR}/lib/${SNPE_PLATFORM_STR}")
set(SNPE_INCLUDE_DIR "${SNPE_SDK_DIR}/include/SNPE")

# =========================================================


set(src_files
    main.cpp
    ObjectDetector.cpp
    SNPEPipeline.cpp
)

add_executable(${PROJECT_NAME} ${src_files})

# --- Include Directories ---
target_include_directories(${PROJECT_NAME} PRIVATE
    "${OpenCV_DIR_INCLUDE}"
    "${gFLAG_DIR_INCLUDE}"
    "${SNPE_INCLUDE_DIR}"
)

# --- Link Directories ---
target_link_directories(${PROJECT_NAME} PRIVATE
    "${OpenCV_DIR_LIB}"
    "${gFLAG_DIR_LIB}"
    "${SNPE_LIB_DIR}"
)

# --- Link Libraries ---
target_link_libraries(${PROJECT_NAME} PRIVATE
    gflags
    opencv_core
    opencv_imgproc
    opencv_highgui
    opencv_imgcodecs
    opencv_videoio
    SNPE
)

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "SNPE lib dir: ${SNPE_LIB_DIR}")
