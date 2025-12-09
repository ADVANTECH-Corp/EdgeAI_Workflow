Developing an Object Detection Model on AOM-DK2721 (Qualcomm/QCS6490) using Qualcomm AI-Hub
===
This example demonstrates how to develop a vision AI model using the Qualcomm AI-Hub on the AOM-DK2721 (Qualcomm QCS6490) platform.
Developers can easily complete the Vision AI development by following these steps.

 Application: Object Detection
* Model: YOLOv11-ONNX / YOLOv11-Quantized
* Input: Video / USB Camera  
![workflow_ai_hub](assets/workflow_ai_hub.png)

## Table of Contents 
- [Environment](#environment) 
  - [Target](#target) 
  - [AI Inference Framework](#ai-inference-framework)
  - [System requirements](#system-requirements) 
- [Development Flow](#development-flow) 
  - [How to use Qualcomm AI Hub on an Ubuntu 22.04 (x86_64) host machine](#how-to-use-qualcomm-ai-hub-on-an-ubuntu-2204-x86_64-host-machine) 
    - [Generate the ONNX model for CPU/iGPU](#generate-the-onnx-model-for-cpuigpu) 
    - [Generate the DLC model for NPU](#generate-the-dlc-model-for-npu) 
  - [How to Develop on a Windows 11 (x86_64) Host Machine](#how-to-develop-on-a-windows-11-x86_64-host-machine) 
    - [Set up Development Environment](#set-up-development-environment) 
    - [For CPU / iGPU](#for-cpu--igpu) 
    - [For NPU](#for-npu) 
  - [Deploy on Target Device(QCS6490)](#deploy-on-target-deviceqcs6490)
    - [Install Edge AI SDK ](#install-edge-ai-sdk)
    - [Run CPU/iGPU](#run-cpuigpu) 
    - [Run NPU](#run-npu)

# Environment
Refer to the following requirements to prepare the target and develop environments.


### Target
| Item | Content | Note |
| -------- | -------- | -------- |
| SOC | Qualcomm QCS6490 | |
| Accelerator | NPU | |
| OS/Build | Windows 11 IoT Enterprise | |
| SDK |  Qualcomm AI Runtime SDK 2.39.0  | |

### AI Inference Framework

| AI Frameworks | Version | Description | 
| -------- | -------- | -------- | 
| SNPE     |    v2.39.0.250926   | The Qualcomm® Neural Processing SDK is a Qualcomm Snapdragon software accelerated runtime for the execution of deep neural networks. With Qualcomm® Neural Processing SDK : <br> * Execute an arbitrarily deep neural network <br> * Execute the network on the Snapdragon CPU, the Adreno GPU or the Hexagon NPU. <br> * Debug the network execution on x86 Ubuntu Linux  <br> * Convert PyTorch, TFLite, ONNX, and TensorFlow models to a Qualcomm® Neural Processing SDK Deep Learning Container (DLC) file  <br> * Quantize DLC files to 8 or 16 bit fixed point for running on the Hexagon NPU  <br> * Debug and analyze the performance of the network with Qualcomm® Neural Processing SDK tools  <br> * Integrate a network into applications and other code via C++ |




### System requirements
| Development Phase | OS | Platform |Requirements|
| -------- | -------- | -------- | -------- |
| Model Generation | Ubuntu 22.04   | x86_64 (Intel 10~13th) | Python 3.10 |
| App Development  | Windows 11     | x86_64 (Intel 10~13th) | Visual Studio 2022,CMake 3.30.4|



# Development Flow

>Note: An active internet connection is required for the entire development flow.

Follow these steps on the development platform (x86_64) to obtain a pre-trained AI model from the Qualcomm AI Hub and then optimize and convert it for the AOM-DK2721 (QCS6490) device.

The development workflow follows a cross-platform approach to leverage Qualcomm AI Hub tools for model optimization and a Windows environment for application development. The process consists of three main stages:

1. `Model Generation (Ubuntu Host)`: Use Qualcomm AI Hub tools on Linux to convert and optimize the YOLOv11 model into ONNX (for CPU/iGPU) or DLC (for NPU) formats.

2. `Application Development (Windows Host)`: Compile the C++ inference application using Visual Studio and the Qualcomm AI Runtime SDK.

3. `Deployment (Target Device)`: Transfer both the optimized model and the compiled executable to the AOM-DK2721 (QCS6490) device to run inference.





## How to use Qualcomm AI Hub on an Ubuntu 22.04 (x86_64) host machine
### Generate the ONNX model for CPU/iGPU
##### Step 1. Install required packages
```
sudo apt install git
sudo apt install python3-pip -y
pip install ultralytics
```
##### Step 2. Convert the YOLOv11n model to yolov11n.onnx
```
mkdir -p ~/yolov11n

cd ~/yolov11n

yolo export model=yolo11n.pt format=onnx opset=13 
```
##### Step 3. Transfer the Model to the Target Device
Copy the ONNX AI model(`yolo11n.onnx`) to target device

---

### Generate the DLC model for NPU
##### Step 1. Sign Up / Log in  (Qualcomm AI Hub)
     https://app.aihub.qualcomm.com/

##### Step 2. Get API Token
>(Text in red is a sample; do not use the actual token shown.)

![ai-hub-setting-token.png](assets/ai-hub-setting.png)

##### Step 3. Install AI-Hub Tool
```
sudo apt install git
sudo apt install python3-pip -y
mkdir -p ~/ai-hub
cd ~/ai-hub
python -m venv ai-hub
source ai-hub/bin/activate
pip install qai_hub_models
```
##### Step 4. Convert the YOLOv11 model to yolov11_det_w8a16.dlc
* Install qai-hub yolov11-det library
  ```
  qai-hub configure --api_token <YOUR_API_TOKEN> (refer to Step 2)

  pip install "qai-hub-models[yolov11-det]"
  ```
* Modify code
  ```
  cd ~/ai-hub/ai-hub/lib/python3.10/site-packages/qai_hub_models/utils
  vim quantization.py
  ```
  Modify line 144 of quantization.py to read:
  ```
  num_samples = int(num_samples or dataset.default_num_calibration_samples())
  ```
* Get yolov11_det_w8a16.dlc
  ```
  python3 -m qai_hub_models.models.yolov11_det.export \
    --quantize w8a16 \
    --target-runtime qnn_dlc \
    --chipset qualcomm-qcs6490-proxy \
    --output-dir ~/ai-hub \
    --height 320 \
    --width 320 \
    --num-calibration-samples 1000
  ```
<a id="ai-hub-version"></a>
* You can verify the required AISDK version during the DLC model generation process.
![](assets/terminal.png)
![](assets/ai-hub.png)


##### Step 5. Transfer the Model to the Target Device
Copy the optimized AI model(`yolov11_det_w8a16.dlc`) to target device

---

## How to Develop on a Windows 11 (x86_64) Host Machine
### Set up Development Environment
##### Environment
 - CMake 3.30.4
 - Visual Studio 2022 (with `Desktop development with C++` workload)
   * **Step 1. Select Base Workload**

      In the Installer, select the `Desktop development with C++` workload.
      
    * **Step 2. Enable ARM64 Support (Crucial)**

      By default, the workload only includes x64/x86 tools. You must manually select the ARM64 compiler for cross-compilation.
      
      Go to `Individual components` and check:

      ![ARM64 Selection](assets/arm64-compiler.png)

    * **Step 3. Verify Configuration**

      Ensure your complete installation matches the list below:
      
      ![Full Configuration Reference](assets/vs_lib.png)


---

##### How to Build
##### Step 1. Clone repo
```
git clone https://github.com/ADVANTECH-Corp/EdgeAI_Workflow.git

cd "EdgeAI_Workflow\ai_system\qualcomm\aom-dk2721\windows\script"
```
##### Step 2. Run `run.bat` to install required packages, including OpenCV 4.11, gflags, These will be installed in `"C:\temp\aisdk"`
```
run.bat
```

##### Step 3. Install [onnxruntime DirectML 1.18.0](https://github.com/microsoft/onnxruntime/releases/download/v1.18.0/Microsoft.ML.OnnxRuntime.DirectML.1.18.0.zip)
* Unzip to `"C:\temp\aisdk"` and set directory name to `Microsoft.ML.OnnxRuntime.DirectML.1.18.0`
  ![vs](assets/lib.png)

##### Step 4. Download [Qualcomm AISDK 2.39.0.250926](https://qpm.qualcomm.com/#/main/tools/details/Qualcomm_AI_Runtime_Community)  and extract it to `"C:\qairt\2.39.0.250926"`(It follows the [AISDK version](#ai-hub-version) )

> To download Qualcomm AI Runtime SDK from Qualcomm Package Manager, ensure that you have registered for a Qualcomm ID. If you don’t have a Qualcomm ID, you will be prompted to register. Then follow the instructions below to download and install the SDK.

![](assets/AISDK.png)
    
---

### For CPU/iGPU

##### Step 1. Clone repo
```
git clone https://github.com/ADVANTECH-Corp/EdgeAI_Workflow.git

cd "EdgeAI_Workflow\ai_system\qualcomm\aom-dk2721\windows\code\cpu_igpu\object-detect"
```
##### Step 2. Execute `build.bat` to generate the executable
```
build.bat
```
* If the build fails, verify the directory paths defined in "CMakeLists.txt" are correct.
  ```
  set(OpenCV_DIR_INCLUDE          "C:\\Temp\\aisdk\\opencv\\include")
  set(OpenCV_DIR_LIB              "C:\\Temp\\aisdk\\opencv\\ARM64/vc17\\lib")
  set(gFLAG_DIR_INCLUDE           "C:\\Temp\\aisdk\\gflags\\mybuild\\build\\include")
  set(gFLAG_DIR_LIB               "C:\\Temp\\aisdk\\gflags\\mybuild\\build\\lib")
  set(ONNXRUNTIME_QNN_DIR_INCLUDE "C:\\Temp\\aisdk\\Microsoft.ML.OnnxRuntime.DirectML.1.18.0\\build\\native\\include")
  set(ONNXRUNTIME_QNN_DIR_LIB     "C:\\Temp\\aisdk\\Microsoft.ML.OnnxRuntime.DirectML.1.18.0\\runtimes\\win-arm64\\native")
  ```

##### Step 3. Transfer executable to Target Device
Copy the executable (`yolov11-object-cpu-igpu.exe`) to the target device

---

### For NPU
##### Step 1. Clone repo
```
git clone https://github.com/ADVANTECH-Corp/EdgeAI_Workflow.git

cd "EdgeAI_Workflow\ai_system\qualcomm\aom-dk2721\windows\code\npu\AI-Hub\object-detect"
```
##### Step 2.  Execute `build.bat` to generate the executable
```
build.bat
```
* If the build fails, verify the directory paths defined in "CMakeLists.txt" are correct.
  ```
  set(OpenCV_DIR_INCLUDE "C:\\Temp\\aisdk\\opencv\\include")
  set(OpenCV_DIR_LIB     "C:\\Temp\\aisdk\\opencv\\ARM64\\vc17\\lib")
  set(gFLAG_DIR_INCLUDE  "C:\\Temp\\aisdk\\gflags\\mybuild\\build\\include")
  set(gFLAG_DIR_LIB      "C:\\Temp\\aisdk\\gflags\\mybuild\\build\\lib")
  set(SNPE_SDK_DIR       "C:\\qairt\\2.39.0.250926") 
  set(SNPE_LIB_DIR       "${SNPE_SDK_DIR}\\lib\\aarch64-windows-msvc")
  set(SNPE_INCLUDE_DIR   "${SNPE_SDK_DIR}\\include\\SNPE")
  ```

##### Step 3. Transfer executable to Target Device
Copy the executable (`yolov11-object-npu-aihub.exe`) to the target device

---

# Deploy on Target Device(QCS6490)

### Install Edge AI SDK 

* Base on Target Environment
* Please install the corresponding version of EdgeAISDK to obtain the following development environment.  
* Install :  [Edge AI SDK(v3.5.0) install](https://happy-coast-0a2494f00.2.azurestaticapps.net/docs/Hardware/AI_System/Qualcomm/)  

### Run CPU/iGPU

> Note: Please ensure that `Git` is installed on your system, and execute the following commands in a `PowerShell` terminal.

##### Step 1. Prepare required files

* Create a new folder
  ```
  mkdir "C:\temp\cpu-igpu"
  ```
* Copy `yolo11n.onnx` (refer to [Generate the ONNX model for CPU/iGPU](#generate-the-onnx-model-for-cpuigpu)) and `yolov11-object-cpu-igpu.exe` (refer to [For CPU/iGPU](#for-cpuigpu)) to `"C:\temp\cpu-igpu"`

* Copy `ObjectDetection.mp4` from the cloned repository to `"C:\temp\cpu-igpu"`
  ```
  git clone https://github.com/ADVANTECH-Corp/EdgeAI_Workflow.git
  cd EdgeAI_Workflow
  Copy-Item "data\video\ObjectDetection.mp4" -Destination "C:\temp\cpu-igpu" -Force
  ```


* After installing `EdgeAISDK 3.5.0`, please copy the necessary files to `"C:\temp\cpu-igpu"`.
  ```
  Copy-Item "C:\Program Files\Advantech\EdgeAI\System\Qualcomm_QCS6490\VisionAI\app\cpu_igpu\coco.txt" -Destination "C:\temp\cpu-igpu" -Force
  Copy-Item "C:\Program Files\Advantech\EdgeAI\System\Qualcomm_QCS6490\VisionAI\app\cpu_igpu\onnxruntime.dll" -Destination "C:\temp\cpu-igpu" -Force   
  Copy-Item "C:\Program Files\Advantech\EdgeAI\System\Qualcomm_QCS6490\VisionAI\lib\*" -Destination "C:\temp\cpu-igpu" -Recurse -Force
  ```

##### Step 2. Run
* Run on CPU
  ```
  cd "C:\temp\cpu-igpu"
  ```
  * Run with USB Camera
    ```
    .\yolov11-object-cpu-igpu.exe --device=CPU --model=yolo11n.onnx --input=0
    ```
  * Run with Video File
    ```
    .\yolov11-object-cpu-igpu.exe --device=CPU --model=yolo11n.onnx --input=ObjectDetection.mp4
    ```
* Run on iGPU
  ```
  cd "C:\temp\cpu-igpu"
  ```
  * Run with USB Camera
    ```
    .\yolov11-object-cpu-igpu.exe --device=GPU --model=yolo11n.onnx --input=0
    ```
  * Run with Video File
    ```
    .\yolov11-object-cpu-igpu.exe --device=GPU --model=yolo11n.onnx --input=ObjectDetection.mp4
    ```

* Result on CPU
![](assets/cpu_infer.png)

* Result on iGPU
![](assets/gpu_infer.png)

---

### Run NPU

> Note: Please ensure that `Git` is installed on your system, and execute the following commands in a `PowerShell` terminal.

##### Step 1. Prepare required files
* Create a new folder
  ```
  mkdir "C:\temp\npu-aihub"
  ```
* Copy `yolov11_det_w8a16.dlc` (refer to [Generate the DLC model for NPU](#generate-the-dlc-model-for-npu)) and `yolov11-object-npu-aihub.exe` (refer to [For NPU](#for-npu)) to `"C:\temp\npu-aihub"`

* Copy `ObjectDetection.mp4` from the cloned repository to `"C:\temp\npu-aihub"`
  ```
  git clone https://github.com/ADVANTECH-Corp/EdgeAI_Workflow.git
  cd EdgeAI_Workflow
  Copy-Item "data\video\ObjectDetection.mp4" -Destination "C:\temp\npu-aihub" -Force
  ```

* After installing `EdgeAISDK 3.5.0`, please copy the necessary files to `"C:\temp\npu-aihub"`.
  ```
  Copy-Item "C:\Program Files\Advantech\EdgeAI\System\Qualcomm_QCS6490\VisionAI\app\cpu_igpu\coco.txt" -Destination "C:\temp\npu-aihub" -Force
  Copy-Item "C:\Program Files\Advantech\EdgeAI\System\Qualcomm_QCS6490\VisionAI\lib\*" -Destination "C:\temp\npu-aihub" -Recurse -Force
  ```



##### Step 2. Run 
* Run on NPU 
  ```
  cd "C:\temp\npu-aihub"
  ```
  * Run with USB Camera
    ```
    .\yolov11-object-npu-aihub.exe `
    --model="yolov11_det_w8a16.dlc" `
    --device=DSP `
    --labels=coco.txt `
    --conf=0.1 `
    --iou=0.45 `
    --layer-names="/Concat_identity,/Cast_identity,/ReduceMax_identity" `
    --input=0
    ```
  * Run with Video File
    ```
    .\yolov11-object-npu-aihub.exe `
    --model="yolov11_det_w8a16.dlc" `
    --device=DSP `
    --labels=coco.txt `
    --conf=0.1 `
    --iou=0.45 `
    --layer-names="/Concat_identity,/Cast_identity,/ReduceMax_identity" `
    --input=ObjectDetection.mp4
    ```
* Result
![](assets/npu_aihub_infer.png)


