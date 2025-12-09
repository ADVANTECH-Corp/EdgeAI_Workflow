cmake_minimum_required(VERSION 3.10)
project(yolov11-object-npu-aihub)

# --- OpenCV ---
set(OpenCV_DIR_INCLUDE "C:\\Temp\\aisdk\\opencv\\include")
set(OpenCV_DIR_LIB   "C:\\Temp\\aisdk\\opencv\\ARM64\\vc17\\lib")

# --- gflags ---
set(gFLAG_DIR_INCLUDE "C:\\Temp\\aisdk\\gflags\\mybuild\\build\\include")
set(gFLAG_DIR_LIB "C:\\Temp\\aisdk\\gflags\\mybuild\\build\\lib")

# --- SNPE SDK ---
set(SNPE_SDK_DIR "C:\\qairt\\2.39.0.250926") 
set(SNPE_LIB_DIR "${SNPE_SDK_DIR}\\lib\\aarch64-windows-msvc") 
set(SNPE_INCLUDE_DIR "${SNPE_SDK_DIR}\\include\\SNPE")

# --- Include all .cpp files ---
set(src_files 
    main.cpp
    ObjectDetector.cpp
    SNPEPipeline.cpp
)

# --- OpenCV  ---
set(_opencv_modules
  core imgproc highgui imgcodecs videoio 
)
set(OPENCV_LIBS "")
foreach(m IN LISTS _opencv_modules)
  file(GLOB _one "${OpenCV_DIR_LIB}/opencv_${m}*.lib")
  list(APPEND OPENCV_LIBS ${_one})
endforeach()

###########################################################################

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
  add_compile_options(/source-charset:utf-8)
endif()

add_executable(${PROJECT_NAME} ${src_files})

# --- Include and Lib directories ---
target_include_directories(${PROJECT_NAME} PRIVATE
  "${OpenCV_DIR_INCLUDE}"
  "${gFLAG_DIR_INCLUDE}"
  "${SNPE_INCLUDE_DIR}" 
)
target_link_directories(${PROJECT_NAME} PRIVATE
  "${OpenCV_DIR_LIB}"
  "${gFLAG_DIR_LIB}"
  "${SNPE_LIB_DIR}"
)

# --- Link libraries ---
target_link_libraries(${PROJECT_NAME} PRIVATE
  gflags 
  ${OPENCV_LIBS}
  SNPE

)

if(MSVC)
  set_property(TARGET ${PROJECT_NAME} PROPERTY
    MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
endif()

message(STATUS "OpenCV libs: ${OPENCV_LIBS}")
message(STATUS "SNPE include: ${SNPE_INCLUDE_DIR}")
message(STATUS "SNPE lib dir: ${SNPE_LIB_DIR}")