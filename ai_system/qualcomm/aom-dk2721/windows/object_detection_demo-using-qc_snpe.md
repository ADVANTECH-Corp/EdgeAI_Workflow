Developing an Object Detection Model on AOM-DK2721 (Qualcomm/QCS6490) using Qualcomm SNPE
===
This example demonstrates how to develop a vision AI model using the Qualcomm SNPE on the AOM-DK2721 (Qualcomm QCS6490) platform.
Developers can easily complete the Vision AI development by following these steps.

 Application: Object Detection
* Model: YOLOv11-ONNX / YOLOv11-Quantized
* Input: Video / USB Camera  
![workflow_snpe](assets/workflow_snpe.png)

## Table of Contents 

- [Environment](#environment) 
  - [Target](#target) 
  - [AI Inference Framework](#ai-inference-framework)
  - [System requirements](#system-requirements) 
- [Development Flow](#development-flow) 
  - [How to use Qualcomm SNPE on an Ubuntu 22.04 (x86_64) host machine](#how-to-use-qualcomm-snpe-on-an-ubuntu-2204-x86_64-host-machine) 
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

Follow these steps on the development platform (x86_64) to prepare a pre-trained AI model and use the Qualcomm SNPE toolchain to optimize and convert it for the AOM-DK2721 (QCS6490) device.

The development workflow follows a cross-platform approach to leverage Qualcomm SNPE-based tools for model optimization and a Windows environment for application development. The process consists of three main stages:

1. `Model Generation (Ubuntu Host)`: Use Qualcomm SNPE tools on Linux to convert and optimize the YOLOv11 model into ONNX (for CPU/iGPU) or DLC (for NPU) formats.

2. `Application Development (Windows Host)`: Compile the C++ inference application using Visual Studio and the Qualcomm AI Runtime SDK.

3. `Deployment (Target Device)`: Transfer both the optimized model and the compiled executable to the AOM-DK2721 (QCS6490) device to run inference.

## How to use Qualcomm SNPE on an Ubuntu 22.04 (x86_64) host machine

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

##### Step 1. Install required packages

```
sudo apt install git
sudo apt install python3-pip -y

mkdir -p ~/snpe
cd ~/snpe
python -m venv snpe
source snpe/bin/activate

pip install ultralytics \
fiftyone \
onnx==1.12.0 \
onnxruntime==1.17.1 \
onnxsim==0.4.36 \
numpy==1.26.4 \
opencv-python==4.6.0.66 \
opencv-python-headless==4.6.0.66

```

##### Step 2. Download [Qualcomm AISDK 2.39.0.250926](https://qpm.qualcomm.com/#/main/tools/details/Qualcomm_AI_Runtime_Community)  and extract it to `"~/Documents"`


> To download Qualcomm AI Runtime SDK from Qualcomm Package Manager, ensure that you have registered for a Qualcomm ID. If you don’t have a Qualcomm ID, you will be prompted to register. Then follow the instructions below to download and install the SDK.

![](assets/AISDK.png)


##### Step 3. Set Qualcomm AISDK

```
cd ~/Documents/v2.39.0.250926/qairt/2.39.0.250926
export SNPE_ROOT=`pwd`
source ${SNPE_ROOT}/bin/envsetup.sh
cd ~/snpe
```

##### Step 4. Convert the YOLOv11n model to yolov11n.onnx

```
yolo export model=yolo11n.pt format=onnx opset=13 imgsz=320
```
* Check yolov11n.onnx output name by using [Netron](https://netron.app/),Default output name is `output0`

  ![alt text](assets/onnx.png)

##### Step 5. Download calibration images and generate a random input list

* Build `get_coco_val.py` and `generate_random_input.py`
  * Clone repo
    ```
    git clone https://github.com/ADVANTECH-Corp/EdgeAI_Workflow.git
    cd EdgeAI_Workflow/ai_system/qualcomm/aom-dk2721/windows/code/npu/SNPE
    ```
  * Copy `get_coco_val.py` and `generate_random_input.py` to `"~/snpe"`
    ```
    mv get_coco_val.py ~/snpe/get_coco_val.py
    mv generate_random_input.py ~/snpe/generate_random_input.py
    cd ~/snpe
    ```
* Execute the following command to generate a dataset of 1,000 COCO images (320x320).
  ```
  python get_coco_val.py
  ```
* Update the output name in `line 10` of `generate_random_input.py` (refer to Step 4); the default value is `output0`.
* Execute the following command to generate a random input list.
  ```
  python generate_random_input.py 
  ```

##### Step 6. Convert ONNX to dlc
Update the out_node; the default value is `output0`
```
${SNPE_ROOT}/bin/x86_64-linux-clang/snpe-onnx-to-dlc  -i yolo11n.onnx \
--out_node output0 \
-o yolov11n.dlc
```

##### Step 7. Quantize DLC model

```
${SNPE_ROOT}/bin/x86_64-linux-clang/snpe-dlc-quantize --input_dlc yolov11n.dlc \
 --input_list img_list.txt \
 --use_enhanced_quantizer \
 --use_adjusted_weights_quantizer \
 --optimizations cle --axis_quant \
 --enable_htp --htp_socs QCS6490 --override_params \
 --act_bitwidth 16 --weights_bitwidth 8 --output_dlc yolov11n-quant.dlc
```

##### Step 8. Check DLC model info

```
${SNPE_ROOT}/bin/x86_64-linux-clang/qairt-dlc-info -i yolov11n-quant.dlc
```
![alt text](assets/dlc-info.png)

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


##### Step 4. Download [Qualcomm AISDK 2.39.0.250926](https://qpm.qualcomm.com/#/main/tools/details/Qualcomm_AI_Runtime_Community)  and extract it to `"C:\qairt\2.39.0.250926"`

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

cd "EdgeAI_Workflow\ai_system\qualcomm\aom-dk2721\windows\code\npu\SNPE\object-detect"
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

Copy the executable (`yolov11-object-npu-snpe.exe`) to the target device

---

# Deploy on Target Device(QCS6490)

### Install Edge AI SDK 

* Base on Target Environment
* Please install the corresponding version of EdgeAISDK to obtain the following development environment.  
* Install :  [Edge AI SDK(v3.5.0) install](https://happy-coast-0a2494f00.2.azurestaticapps.net/docs/Hardware/AI_System/Qualcomm/)  

### Run CPU/iGPU

##### Step 1. Prepare required files

> Note: Please ensure that `Git` is installed on your system, and execute the following commands in a `PowerShell` terminal.
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

##### Step 1. Prepare required files

> Note: Please ensure that `Git` is installed on your system, and execute the following commands in a `PowerShell` terminal.
* Create a new folder
  ```
  mkdir "C:\temp\npu-snpe"
  ```
* Copy `yolov11-quant.dlc` (refer to [Generate the DLC model for NPU](#generate-the-dlc-model-for-npu)) and `yolov11-object-npu-snpe.exe` (refer to [For NPU](#for-npu)) to `"C:\temp\npu-snpe"`

* Copy `ObjectDetection.mp4` from the cloned repository to `"C:\temp\npu-snpe"`
  ```
  git clone https://github.com/ADVANTECH-Corp/EdgeAI_Workflow.git
  cd EdgeAI_Workflow
  Copy-Item "data\video\ObjectDetection.mp4" -Destination "C:\temp\npu-snpe" -Force
  ```

* After installing `EdgeAISDK 3.5.0`, please copy the necessary files to `"C:\temp\npu-snpe"`.
  ```
  Copy-Item "C:\Program Files\Advantech\EdgeAI\System\Qualcomm_QCS6490\VisionAI\app\cpu_igpu\coco.txt" -Destination "C:\temp\npu-snpe" -Force
  Copy-Item "C:\Program Files\Advantech\EdgeAI\System\Qualcomm_QCS6490\VisionAI\lib\*" -Destination "C:\temp\npu-snpe" -Recurse -Force
  ```



##### Step 2. Run 

* Run on NPU 
  ```
  cd "C:\temp\npu-snpe"
  ```
  * Run with USB Camera
    ```
    .\yolov11-object-npu-snpe.exe `
    --model="yolov11n-quant.dlc" `
    --device=DSP `
    --labels=coco.txt `
    --conf=0.1 `
    --iou=0.45 `
    --layer-names="/model.23/Concat_5" `
    --input=0
    ```
  * Run with Video File
    ```
    .\yolov11-object-npu-snpe.exe `
    --model="yolov11n-quant.dlc" `
    --device=DSP `
    --labels=coco.txt `
    --conf=0.1 `
    --iou=0.45 `
    --layer-names="/model.23/Concat_5" `
    --input=ObjectDetection.mp4
    ```
* Result
![](assets/npu_snpe_infer.png)


