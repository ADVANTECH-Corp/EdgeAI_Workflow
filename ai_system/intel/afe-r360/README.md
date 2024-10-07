# Create an Object Detection on AFE-R360 ( Intel / 14th Meteor Lake )
This example will demonstrate how to develop an vision AI Object Detection on AFE-R360 ( Intel 14th Meteor Lake ) platform.
Developers can easily complete the Visual AI development by following these steps.

![eas_ai_workflow](assets/eas_startkit_afe-r360.png)


# 1. Environment
## Target
| Item | Content | Note |
| -------- | -------- | -------- |
| Platform / RAM / Disk |   Intel(R) CoreTM Ultra 7 165U / 32G / 256G  |      |
| SOC | CPU、iGPU、NPU | |
| Accelerator | Intel(R) AI Boost (NPU) | NPU Driver 1.5.1 |
| OS/Kernel | * Ubuntu 24.04 (LTS) / 6.8.0 |  |
| OpenVINO | 2024.3.0 (LTS) | |


## OpenVINO 2024.3.0
- Install OpenVINO™ Runtime on Linux
https://docs.openvino.ai/2024/get-started/install-openvino/install-openvino-archive-linux.html

- How to install, setup 

Complete the installation according to the steps in the link.

![EAS_Startkit_OpenVINO_1](assets/EAS_Startkit_OpenVINO_1.png)

Choose the X86_64 Ubuntu 24.04 option.

![EAS_Startkit_OpenVINO_1](assets/EAS_Startkit_OpenVINO_2.png)

## OpenCV 4.7.0
- OpenCV source
 https://github.com/opencv/opencv.git
- How to install, setup
1. Clone on your device and check out to tag 4.7.0 .

![EAS_Startkit_OpenCV](assets/EAS_Startkit_OpenCV.png)

2. Following the steps below.

- Install the dependency for OpenCV :
```
sudo apt update

sudo apt install build-essential cmake git pkg-config libgtk-3-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3-dev python3-numpy \
    libtbb2 libtbb-dev libopenexr-dev \
    libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev

sudo apt install ffmpeg libavformat-dev libavcodec-dev libswscale-dev
```
- make a file in where you clone
```
mkdir build_470
cd build_470
```
- Install
```
cmake -D CMAKE_BUILD_TYPE=RELEASE -D WITH_FFMPEG=ON -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_GENERATE_PKGCONFIG=ON ..

make -j8

```

## Application Binary
- open model zoo
https://github.com/openvinotoolkit/open_model_zoo/tree/releases/2024/3
- How to install, setup
Clone on your device and check out to tag "releases/2024/3" .

![EAS_Startkit_model-zoo](assets/EAS_Startkit_model-zoo.png)

- NOTE: You must also clone https://github.com/gflags/gflags.git and place it in the following folder.
*`open_model_zoo/demos/thirdparty/gflags/`

- Following the steps below.

**Before you run build_demos, you must export to the *build_470* folder you previously created.**
```
source "/opt/intel/openvino_2024/setupvars.sh"
```
```
export OpenCV_DIR=<path>/build_470
```
```
cd open_model_zoo/demos
./build_demos.sh
```




## NPU Driver (1.5.1)
- NPU Driver
 https://github.com/intel/linux-npu-driver/releases
- How to install
Complete the installation according to the steps in the link.

![EAS_Startkit_NPU](assets/EAS_Startkit_NPU.png)




## iGPU Driver 
- iGPU Driver 
https://github.com/intel/compute-runtime/releases/tag/24.31.30508.7

- How to install
Complete the installation according to the steps in the link. 

![EAS_Startkit_iGPU](assets/EAS_Startkit_iGPU.png)

# 2. Model
- tool : omz_downloader
https://github.com/openvinotoolkit/open_model_zoo/blob/releases/2024/3/tools/model_tools/README.md

## Objection Detection (YOLOX)
- How to obtain:

Install OpenVINO deployment : https://github.com/openvinotoolkit/openvino/tree/master/tools/mo

Following the step.

![EAS_Startkit_openvino_dev](assets/EAS_Startkit_openvino_dev.png)

- YOLOX-OpenVINO in C++
https://github.com/Megvii-BaseDetection/YOLOX/tree/main/demo/OpenVINO/cpp

Go to the link, following "Convert model" part to convert YoloX model.

![EAS_Startkit_convert_model](assets/EAS_Startkit_convert_model.png)

Or, select YOLOX-M, and click github to download the tar file.

![EAS_Startkit_YOLOX](assets/EAS_Startkit_YOLOX.png)

Open the folder, and you will see a model named "***yolox_m.xml***".



# 3. Run Application
## Objection Detection (object_detection_demo)
- Follow the steps in the link
https://github.com/openvinotoolkit/open_model_zoo/tree/releases/2024/3/demos/object_detection_demo/cpp

![EAS_Startkit_run_app_1](assets/EAS_Startkit_run_app_1.png)
![EAS_Startkit_run_app_2](assets/EAS_Startkit_run_app_2.png)

- Example
```
cd /$HOME/omz_demos_build/intel64/Release
```
```
source "/opt/intel/openvino_2024/setupvars.sh"
./object_detection_demo -m <path_to_model>/yolox.xml -d CPU -i <path_to_video>/TestVideo.mp4 -at yolox -loop
```

Result:

![EAS_Startkit_object-detection](assets/EAS_Startkit_object-detection.png)
