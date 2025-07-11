# Create an Object Detection Demo on AOM-DK2721 ( Qualcomm/QCS6490 ) using Qualcomm SNPE
This example will demonstrate how to develop an vision AI Object Detection on AOM-DK2721 ( Qualcomm QCS6490 ) platform.
Developers can easily complete the Visual AI development by following these steps.

* Application: Objection Detection
* Model: Yolo
* Input: Video / USB Camera

# Table of Contents
- [Environment](#Environment)
  - [Target](#Target)
  - [Development](#Development) 
- [Develop Flow](#DevelopFlow)
  - [Open AI Model](#Open_AI_Model)
- [Deploy](#Deploy)
  - [Application](#Application)

<a name="Environment"/>

# Environment
Refer to the following requirements to prepare the target and develop environment.

<a name="Target"/>

## Target
| Item | Content | Note |
| -------- | -------- | -------- |
| Platform / RAM / Disk |  Arm64 Cortex-A55    |      |
| SOC | Qualcomm QCS6490 | |
| Accelerator | DSP | |
| OS/Kernel | LE/QIRP1.1 Yocto-4.0 / 6.6.28 | |
| BSP | qcs6490aom2721a1 | |

AI Inference Framework

| AI Frameworks | Version | Description | 
| -------- | -------- | -------- | 
| SNPE     | v2.20.0.240223    | The Qualcomm® Neural Processing SDK is a Qualcomm Snapdragon software accelerated runtime for the execution of deep neural networks. With Qualcomm® Neural Processing SDK : <br> * Execute an arbitrarily deep neural network <br> * Execute the network on the Snapdragon CPU, the Adreno GPU or the Hexagon DSP. <br> * Debug the network execution on x86 Ubuntu Linux  <br> * Convert PyTorch, TFLite, ONNX, and TensorFlow models to a Qualcomm® Neural Processing SDK Deep Learning Container (DLC) file  <br> * Quantize DLC files to 8 or 16 bit fixed point for running on the Hexagon DSP  <br> * Debug and analyze the performance of the network with Qualcomm® Neural Processing SDK tools  <br> * Integrate a network into applications and other code via C++ or Java |
| Gstreamer     |  1.20.7   | GStreamer is a library for constructing graphs of media-handling components. The applications it supports range from simple Ogg/Vorbis playback, audio/video streaming to complex audio (mixing) and video (non-linear editing) processing. |

<a name="Development"/>

## Development
System requirements
| Item | Content | Note |
| -------- | -------- | -------- |
| Platform | Intel 10 ~ 13th CPU   |  x86_64    |
| OS/Kernel | Ubuntu 20.04 | * Python 3.8 |

AI Development SDK 
| Item | Introduction |  Install |
| -------- | -------- | -------- |
|   SNPE   |  Qualcomm Snapdragon software accelerated runtime for the execution of deep neural networks (for inference) with SNPE, users can:Convert Caffe, Caffe2, TensorFlow, PyTorch and TFLite models to a SNPE deep learning container (DLC) fileQuantize DLC files to 8bit/16bit fixed point for execution on the Qualcomm® Hexagon™ DSP/HVX HTA Integrate a network into applications and other code via C++ or Java Execute the network on the Snapdragon CPU, the Qualcomm® AdrenoTM GPU, or the Hexagon DSP with HVX* and HMX* support, Execute an arbitrarily deep neural network Debug the network model execution on x86 Ubuntu Linux Debug and analyze the performance of the network model with SNPE tools Benchmark a network model for different targets  |     


How to intsll the SNPE on x86_x64 host machine
1. Sign Up Qualcomm Account My Account (qualcomm.com): https://myaccount.qualcomm.com/signup

2. Download and Install Qualcomm Package Manager 3: https://qpm.qualcomm.com/#/main/tools/details/QPM3

3. Download and Install Qualcomm® AI Engine Direct SDK: https://qpm.qualcomm.com/#/main/tools/details/qualcomm_ai_engine_direct

4. Download and Install Qualcomm® Neural Processing SDK: https://qpm.qualcomm.com/#/main/tools/details/qualcomm_neural_processing_sdk

5. Install ML frameworks:
    - pip install onnx==1.11.0
    - pip install tensorflow==2.10.1
    - pip install torch==1.13.1"



<a name="DevelopFlow"/>

# Develop Flow
Follow these steps on the development platform (x86_64) to obtain a pre-trained AI model from the Qualcomm AI Hub or an open AI model, then optimize and convert it for the AOM-DK2721 (QCS6490) device. <br>
 
<a name="Open_AI_Model"/>

## Open AI Model 
- 1. Download Model (pt) 
     [yolov5n.pt](https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5n.pt)
     on https://github.com/ultralytics/yolov5
     
- 2. Convert (pt -> onnx)  
     - step-1: git clone https://github.com/ultralytics/yolov5
     - step-2: cd yolov5
     - step-3: pip install -r requirements.txt   
     - step-4: python export.py --weights yolov5n.pt --include onnx --imgsz 320

- 3. Convert & Optimize (onnx -> dlc), Refer to document below:<br>
      - step-1: To download file: [Reference Document Link](https://docs.qualcomm.com/bundle/publicresource/KBA-240222225148_REV_1_Quick_Start_Demo_of_SNPE_Yolov5_in_6490.pdf)
      - step-2: To execute the step1 to step6 of the download file. 
- 4.  To get label file:<br>
      - git clone https://github.com/ADVANTECH-Corp/EdgeAI_Workflow.git
      - EdgeAI_Workflow\ai_system\qualcomm\aom-dk2721\labels\yolov5.labels
 
<a name="Deploy"/>

# Deploy
Copy the optimized AI model to target device and  launch an AI application with gstream pipeline.

<a name="Application"/>

## Application
| Device   | Command  | Introduction  |
| -------- | -------- | ------------- |
| AOM-DK2721 | export XDG_RUNTIME_DIR=/dev/socket/weston <br> export WAYLAND_DISPLAY=wayland-1 <br> source /opt/qcom/qirp-sdk/qirp-setup.sh <br> gst-launch-1.0 -e qtivcomposer name=mixer sink_1::dimensions="<1920,1080>" ! queue ! waylandsink sync=true fullscreen=false x=10 y=10 width=1280 height=720 v4l2src device="/dev/video2"  ! tee name=t ! queue ! mixer. t. ! queue ! qtimlvconverter mean="<0.0, 0.0, 0.0>" sigma="<0.003921, 0.003921, 0.003921>" ! queue ! qtimlsnpe delegate=dsp model="yolov5n-quant.dlc" layers="</model.24/m.0/Conv,/model.24/m.1/Conv,/model.24/m.2/Conv>" ! queue ! qtimlvdetection threshold=51.0 results=10 module=yolov5 labels="yolov5.labels" ! video/x-raw,width=480,height=270 ! queue ! mixer. | Run on dsp (usb camera) |
| AOM-DK2721 | export XDG_RUNTIME_DIR=/dev/socket/weston <br> export WAYLAND_DISPLAY=wayland-1 <br> source /opt/qcom/qirp-sdk/qirp-setup.sh <br> gst-launch-1.0 -e qtivcomposer name=mixer sink_1::dimensions="<1920,1080>" ! queue ! waylandsink sync=true fullscreen=false x=10 y=10 width=1280 height=720 filesrc  location="file.mp4" ! qtdemux ! queue ! h264parse ! v4l2h264dec capture-io-mode=5 output-io-mode=5 ! queue ! tee name=t ! queue ! mixer.  t. ! queue ! qtimlvconverter mean="<0.0, 0.0, 0.0>" sigma="<0.003921, 0.003921, 0.003921>" ! queue ! qtimlsnpe delegate=dsp model="yolov5n-quant.dlc" layers="</model.24/m.0/Conv,/model.24/m.1/Conv,/model.24/m.2/Conv>" ! queue !  qtimlvdetection threshold=51.0 results=10 module=yolov5 labels="yolov5.labels" ! video/x-raw,width=480,height=270 ! queue ! mixer. | Run on dsp (video file) |
## Result

![eas_ai_workflow](assets/rom-2860_objectdetection_result.png)
