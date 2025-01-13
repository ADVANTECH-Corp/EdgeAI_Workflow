# Create an Object Detection on AOM-2721 ( Qualcomm/QCS6490 )
This example will demonstrate how to develop an vision AI Object Detection on AOM-2721 ( Qualcomm QCS6490 ) platform.
Developers can easily complete the Visual AI development by following these steps.

 

# Environment
## Target
| Item | Content | Note |
| -------- | -------- | -------- |
| Platform / RAM / Disk |  Arm64 Cortex-A55    |      |
| SOC | Qualcomm QCS6490 | |
| Accelerator | DSP | |
| OS/Kernel | LE/QIRP1.1 Yocto-4.0 / 6.6.28 | |
| BSP | 2721A1AIM38LIV11033 | |
 

### AI Development SDK 
| Item | Introduction |  Install |
| -------- | -------- | -------- |
|   SNPE   |  Qualcomm Snapdragon software accelerated runtime for the execution of deep neural networks (for inference) with SNPE, users can:Convert Caffe, Caffe2, TensorFlow, PyTorch and TFLite models to a SNPE deep learning container (DLC) fileQuantize DLC files to 8bit/16bit fixed point for execution on the Qualcomm® Hexagon™ DSP/HVX HTA Integrate a network into applications and other code via C++ or Java Execute the network on the Snapdragon CPU, the Qualcomm® AdrenoTM GPU, or the Hexagon DSP with HVX* and HMX* support, Execute an arbitrarily deep neural network Debug the network model execution on x86 Ubuntu Linux Debug and analyze the performance of the network model with SNPE tools Benchmark a network model for different targets  |     

#### SNPE Install ( x64 )
1. Ubuntu 20.04 with Python 3.8
2. Sign Up Qualcomm Account My Account (qualcomm.com): https://myaccount.qualcomm.com/signup

3. Install Qualcomm Package Manager 3: https://qpm.qualcomm.com/#/main/tools/details/QPM3

4. Install Qualcomm® AI Engine Direct SDK: https://qpm.qualcomm.com/#/main/tools/details/qualcomm_ai_engine_direct

5. Install Qualcomm® Neural Processing SDK: https://qpm.qualcomm.com/#/main/tools/details/qualcomm_neural_processing_sdk

6. Install ML frameworks:
    pip install onnx==1.11.0
    pip install tensorflow==2.10.1
    pip install torch==1.13.1"


### AI Inference Framework
| AI Frameworks | Version | Description | 
| -------- | -------- | -------- | 
| SNPE     | v2.20.0.240223    | The Qualcomm® Neural Processing SDK is a Qualcomm Snapdragon software accelerated runtime for the execution of deep neural networks. With Qualcomm® Neural Processing SDK : <br> * Execute an arbitrarily deep neural network <br> * Execute the network on the Snapdragon CPU, the Adreno GPU or the Hexagon DSP. <br> * Debug the network execution on x86 Ubuntu Linux  <br> * Convert PyTorch, TFLite, ONNX, and TensorFlow models to a Qualcomm® Neural Processing SDK Deep Learning Container (DLC) file  <br> * Quantize DLC files to 8 or 16 bit fixed point for running on the Hexagon DSP  <br> * Debug and analyze the performance of the network with Qualcomm® Neural Processing SDK tools  <br> * Integrate a network into applications and other code via C++ or Java |
| Gstreamer     |  1.16.3   | GStreamer is a library for constructing graphs of media-handling components. The applications it supports range from simple Ogg/Vorbis playback, audio/video streaming to complex audio (mixing) and video (non-linear editing) processing. |




## Device Information 

| Hardware | Packages  | 
| ----------- |  ---------- |
| * QCS6490  <br>  ** Yocto-4.0  <br>(kernel: 6.6.28)  | * SNPE (runtime)<br> * Gstreamer <br> 
 


# Develop Flow
Application: Objection Detection
Model:Yolov5
Input: Video / USB Camera

## AI Model
### Download pre-trained AI Model from Qualcomm AI Hub
- 1. Download Model from AI Hub

### Download AI Model and Convert (Object detection)
- 1. Download Model (pt) 
     [yolov5n.pt](/xdept/public/autoinsert/yolov5n_1727345998107.pt)
     refer to https://github.com/ultralytics/yolov5 
 
- 2. Convert (pt -> onnx) 
     refer to `export.py` within https://github.com/ultralytics/yolov5 
 
- 3. Convert (onnx -> dlc), Refer to document below:
 [kba-240222225148_rev_1_quick_start_demo_of_snpe_yolov5_in_6490_1727340915309.pdf](/xdept/public/autoinsert/kba-240222225148_rev_1_quick_start_demo_of_snpe_yolov5_in_6490_1727340915309.pdf)
 


## Application
| Device   | Command  | Introduction  |
| -------- | -------- | ------------- |
| AOM-2721 |   gst-launch-1.0 -e qtivcomposer name=mixer sink_1::dimensions="<1920,1080>" ! queue ! waylandsink sync=true fullscreen=false x=10 y=10 width=1280 height=720 v4l2src device="/dev/video0"  ! tee name=t ! queue ! mixer. t. ! queue ! qtimlvconverter mean="<0.0, 0.0, 0.0>" sigma="<0.003921, 0.003921, 0.003921>" ! queue ! qtimlsnpe delegate=dsp model="yolov5n-quant.dlc" layers="< Conv_266, Conv_232, Conv_198 >" ! queue ! qtimlvdetection threshold=51.0 results=10 module=yolov5 labels="yolov5.labels" ! video/x-raw,width=480,height=270 ! queue ! mixer. | Run on dsp (usb camera) |
| AOM-2721 | gst-launch-1.0 -e qtivcomposer name=mixer sink_1::dimensions="<1920,1080>" ! queue ! waylandsink sync=true fullscreen=false x=10 y=10 width=1280 height=720 filesrc  location="$inputfile" ! qtdemux ! queue ! h264parse ! qtivdec ! queue ! tee name=t ! queue ! mixer.  t. ! queue ! qtimlvconverter mean="<0.0, 0.0, 0.0>" sigma="<0.003921, 0.003921, 0.003921>" ! queue ! qtimlsnpe delegate=dsp model="yolov5n-quant.dlc" layers="< Conv_266, Conv_232, Conv_198 >" ! queue !  qtimlvdetection threshold=51.0 results=10 module=yolov5 labels="yolov5.labels" ! video/x-raw,width=480,height=270 ! queue ! mixer. | Run on dsp (video file) |
## Result

![eas_ai_workflow](assets/rom-2860_objectdetection_result.png)


# Benchmark
| Device   | Command  | Introduction  |
| -------- | -------- | ------------- |
| AOM-2721 | snpe-throughput-net-run --duration 5 --perf_profile burst --use_dsp --userbuffer_auto --container mobilenet_v1_ssd_2017_quantized.dlc |Run on dsp |
 
 


  
