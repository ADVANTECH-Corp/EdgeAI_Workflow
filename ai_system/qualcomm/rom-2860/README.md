# Create an Object Detection on ROM-2860 ( Qualcomm/QCS6490 )
This example will demonstrate how to develop an vision AI Object Detection on ROM-2860 ( Qualcomm QCS6490 ) platform.
Developers can easily complete the Visual AI development by following these steps.

![eas_ai_workflow](assets/eas_startkit_rom-2860.png)




 ## Information


| Version | Date | Hardware | Packages & Functions | 
| -------- | -------- | ----------- |  ---------- |
| 3.1.0-beta-1|2024-09-24 | * QCS6490  <br>  ** Ubuntu 20.04  <br>(kernel: 5.4.233)  | * SNPE (runtime)<br> * Gstreamer <br> * Vision AI Models:  <br>  yolov5 <br>  face-detection   
 


| AI Frameworks | Version | Description | 
| -------- | -------- | -------- | ---- |
| SNPE     | v2.20.0.240223    | The Qualcomm® Neural Processing SDK is a Qualcomm Snapdragon software accelerated runtime for the execution of deep neural networks. With Qualcomm® Neural Processing SDK : <br> * Execute an arbitrarily deep neural network <br> * Execute the network on the Snapdragon CPU, the Adreno GPU or the Hexagon DSP. <br> * Debug the network execution on x86 Ubuntu Linux  <br> * Convert PyTorch, TFLite, ONNX, and TensorFlow models to a Qualcomm® Neural Processing SDK Deep Learning Container (DLC) file  <br> * Quantize DLC files to 8 or 16 bit fixed point for running on the Hexagon DSP  <br> * Debug and analyze the performance of the network with Qualcomm® Neural Processing SDK tools  <br> * Integrate a network into applications and other code via C++ or Java |
| Gstreamer     |  1.16.3   | GStreamer is a library for constructing graphs of media-handling components. The applications it supports range from simple Ogg/Vorbis playback, audio/video streaming to complex audio (mixing) and video (non-linear editing) processing. |
 


# How To
## Download


 
* Edge AI SDK 3.1.0-beta-1
    * `\\eossfs\ESS-Release\EdgeSense\Release\EdgeAISDK\v3.1.0\Edge_AI_SDK_Installer-QCS6490-3.1.0_beta-1.tar.gz`
    
## Install

* tar -zxvf Edge_AI_SDK_Installer-QCS6490-3.1.0_beta-1.tar.gz
* ./Edge_AI_SDK-installer.run
   
   
## Start EdgeAISDK

 * 1 open terminal
 * 2 execute script : /opt/Advantech/EdgeAISuite/MainAPP/QCS6490/app.sh
 
 ![未命名_1727321765616.png](/xdept/public/autoinsert/未命名_1727321765616.png)
  
 
## Vision AI Inference Application
* Step 1 : Go to the " Quick start VisionAI" page as show below
* Step 2 : Choose one application you want to 

 ![4_1727331586152.png](/xdept/public/autoinsert/4_1727331586152.png)
![1_1727331612385.png](/xdept/public/autoinsert/1_1727331612385.png)
## Close AI Inference Application

 * 1 EdgeAISDk (GUI) show in the top .
 * 2 Press Key "Esc"  
 ![wayland-screenshot-2024-09-26_02-17-25_1727321544457.png](/xdept/public/autoinsert/wayland-screenshot-2024-09-26_02-17-25_1727321544457.png)

 
## System Monitoring 
![3_1727331871209.png](/xdept/public/autoinsert/3_1727331871209.png)
 
## AI Inference Benchmark
It can quickly evaluate computing performance for the DSP, and provides runtime results inferenced with ML.
![2_1727331888480.png](/xdept/public/autoinsert/2_1727331888480.png)


