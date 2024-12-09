# Create an Object Detection on AFE-R360 ( Intel / 14th Meteor Lake )
This example will demonstrate how to develop an vision AI Object Detection on AFE-R360 ( Intel 14th Meteor Lake ) platform.
Developers can easily complete the Visual AI development by following these steps.

![eas_ai_workflow](assets/eas_startkit_afe-r360.png)

- [Environment](#Environment)
  - [Target](#Target)
  - [Develop](#Develop) 
- [Develop Flow](#DevelopFlow)
  - [Download model](#DownloadModel)
  - [Convert & Optimize](#Covert_Optimize) 
- [Deploy](#Deploy)
  - [Application](#Application)

<a name="Environment"/>

# Environment
Refer to the following requirements to prepare the target and develop environment.

<a name="Target"/>

## Target
| Item | Content | Note |
| -------- | -------- | -------- |
| Platform |   AFE-R360  |   RAM : 32G / Disk : 256G   |
| CPU  |   Intel(R) CoreTM Ultra 7 165U |  |
| iGPU | Meteor Lake-P | |
| NPU | Intel(R) AI Boost (NPU) | NPU Driver 1.5.1 |
| OS/Kernel | * Ubuntu 24.04 (LTS) / 6.8.0 |  |
| OpenVINO | 2024.3.0 (LTS) | |

Base on **EdgeAI SDK 3.1.0**

<a name="Develop"/>

## Develop

Base on **Target Environment**

| Item | Introduction | Version |
| -------- | -------- | -------- |
| OpenCV | https://github.com/opencv/opencv.git    | 4.7.0 |
| open model zoo  | https://github.com/openvinotoolkit/open_model_zoo/tree/releases/2024/3   | 2024.3.0  |
| openvino-dev  | Contains omz_downloader & omz_converter tools<br>https://github.com/openvinotoolkit/open_model_zoo/blob/releases/2024/3/tools/model_tools/README.md  | |
| tensorflow  | https://www.tensorflow.org/   | |

<br/>

### Install OpenCV (4.7.0)
- How to install, setup

Clone on your device and check out to tag 4.7.0 .

```
cd /home/$USER/Downloads
git clone https://github.com/opencv/opencv.git
git checkout 4.7.0
```

- Following the steps below.

Install the dependency for OpenCV :
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
make a file in where you clone
```
cd opencv
mkdir build_470
cd build_470
```
Install
```
cmake -D CMAKE_BUILD_TYPE=RELEASE -D WITH_FFMPEG=ON -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_GENERATE_PKGCONFIG=ON ..

make -j8
```
<br/>

### Install open model zoo
- How to install, setup

Clone on your device and check out to tag "releases/2024/3" .
```
cd home/$USER/Downloads
git clone https://github.com/openvinotoolkit/open_model_zoo.git
git checkout 2024.3.0
cd open_model_zoo
git submodule init
git submodule update
```

- Following the steps below.

Before you run build_demos, you must export to the *build_470* folder you previously created.
```
source "/opt/intel/openvino_2024/setupvars.sh"
```
```
export OpenCV_DIR=/home/$USER/Downloads/opencv/build_470
```
Install
```
cd open_model_zoo/demos
./build_demos.sh
```
- Check
```
ls /$HOME/omz_demos_build/intel64/Release
```
If the installation fails, it will display ”No such file or directory”.

<br/>

### Install openvino-dev & tensorflow
- How to install, setup
  
Build the python virtual environment
```
sudo apt install python3.12-venv
python3 -m venv <env-name>
```

- Following the steps below.
  
Install
```
source /home/$USER/<env-name>/bin/activate

pip install openvino-dev
pip install tensorflow
```

<a name="DevelopFlow"/>

# Develop Flow
Follow these steps to get and optimize the VisionAI model. <br>

<a name="DownloadModel"/>

### Download Model
```
source /home/$USER/<env-name>/bin/activate
cd Download/open_model_zoo/models/public

omz_downloader --name yolo-v3-tf
```

<a name="Covert_Optimize"/>

### Covert & Optimize Model
```
source /home/$USER/<env-name>/bin/activate
cd Download/open_model_zoo/models/public

omz_converter --name yolo-v3-tf
```
### Check
The converted model will be placed in /home/$USER/Downloads/open_model_zoo/models/pulic/pulic/yolo-v3-tf/FP16/yolo-v3-tf.xml


<a name="Deploy"/>

# Deploy
Launch an AI application.

<a name="Application"/>

## Run Application
### Objection Detection (object_detection_demo)

```
cd /$HOME/omz_demos_build/intel64/Release
```

PATH
- model : /home/$USER/Downloads/open_model_zoo/models/pulic/pulic/yolo-v3-tf/FP16/yolo-v3-tf.xml
- video : /home/$USER/Downloads/EdgeAI_Workflow/data/video/ObjectDetection.mp4

```
source "/opt/intel/openvino_2024/setupvars.sh"

./object_detection_demo -m /home/$USER/Downloads/open_model_zoo/models/pulic/pulic/yolo-v3-tf/FP16/yolo-v3-tf.xml -d CPU -i /home/$USER/Downloads/EdgeAI_Workflow/data/video/ObjectDetection.mp4 -at yolo -loop
```

Result:

![EAS_Startkit_object-detection](assets/EAS_Startkit_object-detection.png)

- See more on
https://github.com/openvinotoolkit/open_model_zoo/tree/releases/2024/3/demos/object_detection_demo/cpp
