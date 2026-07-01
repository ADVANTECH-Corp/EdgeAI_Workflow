# Create an Object Detection

This example demonstrates how to prepare an OpenVINO object detection model and run the Open Model Zoo Object Detection C++ demo on an Advantech EdgeAI Intel platform.



- [Environment](#environment)
  - [Target](#target)
  - [Development](#model-conversion) 
- [Develop Flow](#develop-flow)
  - [Prepare Workspace](#prepare-workspace)
  - [Prepare Environment](#prepare-model-conversion-environment)
  - [Download model](#download-model)
  - [Convert model](#convert-model) 
  - [Build Demo](#build-object-detection-demo) 
- [Deploy](#deploy)
  - [Application](#run-cpu)


</br>





# Environment

Refer to the following requirements to prepare the target and development environment.

Base on **Edge AI SDK**

## Target

| Item | Content | Note |
| --- | --- | --- |
| Platform | Advantech EdgeAI Intel platform | CPU / iGPU / NPU |
| OS | Windows 11 | Command Prompt or PowerShell |
| Product Miniconda | `C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3` | Used to create the model conversion environment |
| Runtime conda env | `vision-runtime-py310` | Created by this guide to run the C++ demo |
| Model | `ssd_mobilenet_v1_coco` | Public Open Model Zoo model |
| Architecture type | `ssd` | Passed to `object_detection_demo.exe` by `-at ssd` |





## Model Conversion

The model conversion flow uses Python 3.10 and legacy Open Model Zoo tools. This is intentional because `omz_converter` for this TensorFlow object detection model still uses the legacy Model Optimizer flow.

| Item | Introduction | Version |
| --- | --- | --- |
| Python | | 3.10 |
| numpy | | 1.26.x |
| OpenCV | https://github.com/opencv/opencv.git    | 4.13.0 |
| open model zoo  | https://github.com/openvinotoolkit/open_model_zoo/tree/releases/2026/1   | releases/2026/1  |
| OpenVINO | https://docs.openvino.ai/2026/index.html | 2026.1.0 |
| openvino-dev  | Contains omz_downloader & omz_converter tools<br>https://github.com/openvinotoolkit/open_model_zoo/tree/releases/2026/1/tools/model_tools  | 2024.6.0 |
| tensorflow  | https://www.tensorflow.org/   | 2.15.1 |






# Develop Flow

Follow these steps to download and convert the model, then build the demo executable.



## Prepare Workspace

```bat
set "CONDA_ROOT=C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3"
set "WORKSPACE=C:\Advantech\VisionAI"
set "MODEL_ROOT=%WORKSPACE%\models"
set "CONVERT_ENV=%WORKSPACE%\envs\omz-py310"
set "RUNTIME_ENV=%WORKSPACE%\envs\vision-runtime-py310"

mkdir "%WORKSPACE%"
mkdir "%MODEL_ROOT%"
```

Check disk space before downloading and converting models:

```powershell
Get-PSDrive C | Select-Object Name,Free,Used
```

Clone Open Model Zoo 2026.1:

```bat
cd /d "%WORKSPACE%"
git clone https://github.com/openvinotoolkit/open_model_zoo.git
cd open_model_zoo
git checkout releases/2026/1
git submodule update --init --recursive
```



## Prepare Model Conversion Environment

Create a Python 3.10 conversion environment:

```bat
"%CONDA_ROOT%\Scripts\conda.exe" create -p "%CONVERT_ENV%" python=3.10 -y
```

If `conda create` prints `SafetyError` messages from the product Miniconda package cache, first continue with the checks below. If the created environment runs and the package checks pass, the environment is usable. If Python or package installation fails, clean or repair the product Miniconda package cache, then create the environment again.

Install model conversion packages:

```bat
"%CONVERT_ENV%\python.exe" -m pip install --upgrade pip setuptools wheel
"%CONVERT_ENV%\python.exe" -m pip install openvino-dev==2024.6.0
"%CONVERT_ENV%\python.exe" -m pip install tensorflow==2.15.1
```

Check:

```bat
"%CONVERT_ENV%\python.exe" --version
"%CONVERT_ENV%\python.exe" -m pip show openvino-dev openvino tensorflow numpy
"%CONVERT_ENV%\Scripts\omz_downloader.exe" --help
"%CONVERT_ENV%\Scripts\omz_converter.exe" --help
```



## Prepare Runtime Environment

Create a separate runtime environment for the C++ demo:

```bat
"%CONDA_ROOT%\Scripts\conda.exe" create -p "%RUNTIME_ENV%" python=3.10 -y
```

The same `SafetyError` guidance applies here: treat it as blocking only if the environment cannot run or the package checks fail.

Install OpenVINO runtime:

```bat
"%RUNTIME_ENV%\python.exe" -m pip install --upgrade pip
"%RUNTIME_ENV%\python.exe" -m pip install openvino==2026.1.0
```

Check:

```bat
"%RUNTIME_ENV%\python.exe" --version
"%RUNTIME_ENV%\python.exe" -m pip show openvino numpy
```



## Download Model

Download `ssd_mobilenet_v1_coco`:

```bat
cd /d "%WORKSPACE%\open_model_zoo\models\public"

"%CONVERT_ENV%\Scripts\omz_downloader.exe" ^
  --name ssd_mobilenet_v1_coco ^
  --output_dir "%MODEL_ROOT%"
```



## Convert Model

Convert the model to OpenVINO IR:

```bat
cd /d "%WORKSPACE%\open_model_zoo\models\public"

"%CONVERT_ENV%\Scripts\omz_converter.exe" ^
  --name ssd_mobilenet_v1_coco ^
  --download_dir "%MODEL_ROOT%" ^
  --output_dir "%MODEL_ROOT%" ^
  --mo "%CONVERT_ENV%\Scripts\mo.exe"
```

The expected model files are:

```bat
dir "%MODEL_ROOT%\public\ssd_mobilenet_v1_coco\FP16\ssd_mobilenet_v1_coco.xml"
dir "%MODEL_ROOT%\public\ssd_mobilenet_v1_coco\FP16\ssd_mobilenet_v1_coco.bin"
```

The `.xml` file is the model file passed to `object_detection_demo.exe`. Keep the `.bin` file in the same folder.



## Build Object Detection Demo

The Object Detection demo source is located in:

```text
%WORKSPACE%\open_model_zoo\demos\object_detection_demo\cpp
```

Build requirements:

* Microsoft Visual Studio Build Tools with C++ workload
* CMake
* OpenCV C++ package
* OpenVINO C++ runtime package or another OpenVINO package that provides `OpenVINOConfig.cmake`

Download OpenCV 4.13.0 from the OpenCV release page:

[Download Link OpenCV 4.13.0](https://github.com/opencv/opencv/releases/download/4.13.0/opencv-4.13.0-windows.exe)


This guide assumes OpenCV is extracted to:

```text
C:\opencv
```

When using the OpenCV Windows self-extractor, extract it to `C:\` so the final folder becomes:

```text
C:\opencv\build
```

If you extract to `C:\opencv`, the self-extractor may create `C:\opencv\opencv\build` instead. In that case, either move the folder back to `C:\opencv\build` or update `OpenCV_DIR` and `OPENCV_BIN` to the actual path.

Example build flow:

```bat
cd /d "%WORKSPACE%"
mkdir build
cd build
mkdir omz_demos_build
cd omz_demos_build

cmake ^
  -DOpenCV_DIR="C:\opencv\build" ^
  -DOpenVINO_DIR="%RUNTIME_ENV%\Lib\site-packages\openvino\cmake" ^
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
  "%WORKSPACE%\open_model_zoo\demos"

cmake --build . --config Release --target object_detection_demo
```

If you run the CMake configure command in PowerShell, quote the CMake policy argument:

```powershell
cmake `
  -DOpenCV_DIR="C:\opencv\build" `
  -DOpenVINO_DIR="$env:RUNTIME_ENV\Lib\site-packages\openvino\cmake" `
  '-DCMAKE_POLICY_VERSION_MINIMUM=3.5' `
  "$env:WORKSPACE\open_model_zoo\demos"
```

Expected output:

```text
%WORKSPACE%\build\omz_demos_build\intel64\Release\object_detection_demo.exe
```

Copy the OpenCV runtime DLL to the demo executable folder:

```bat
copy "C:\opencv\build\x64\vc16\bin\opencv_world*.dll" "%WORKSPACE%\build\omz_demos_build\intel64\Release\"
dir "%WORKSPACE%\build\omz_demos_build\intel64\Release\opencv_world*.dll"
```

If the Advantech product already includes `object_detection_demo.exe`, you can use the product executable instead:

```text
C:\Program Files\Advantech\EdgeAI\System\Intel\VisionAI\app\object_detection\object_detection_demo.exe
```



# Deploy

Launch the Object Detection demo with the runtime environment created by this guide.

Set common paths:

```bat
set "CONDA_ROOT=C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3"
set "RUNTIME_ENV=C:\Advantech\VisionAI\envs\vision-runtime-py310"

set "APP_DIR=C:\Advantech\VisionAI\build\omz_demos_build\intel64\Release"
set "APP_EXE=%APP_DIR%\object_detection_demo.exe"
set "MODEL_XML=C:\Advantech\VisionAI\models\public\ssd_mobilenet_v1_coco\FP16\ssd_mobilenet_v1_coco.xml"
set "EDGEAI_WORKFLOW=<repo>\EdgeAI_Workflow"
set "VIDEO=%EDGEAI_WORKFLOW%\data\video\ObjectDetection.mp4"
```

`ObjectDetection.mp4` is included in this repository under `data\video`. If the repository is not already on the target machine, clone or copy it first, then set `EDGEAI_WORKFLOW` to that local repository path.

```bat
cd /d "%WORKSPACE%"
git clone https://github.com/ADVANTECH-Corp/EdgeAI_Workflow.git
set "EDGEAI_WORKFLOW=%WORKSPACE%\EdgeAI_Workflow"
set "VIDEO=%EDGEAI_WORKFLOW%\data\video\ObjectDetection.mp4"
```

If the Advantech product already includes `object_detection_demo.exe`, you can use the product executable instead:

```bat
set "APP_EXE=C:\Program Files\Advantech\EdgeAI\System\Intel\VisionAI\app\object_detection\object_detection_demo.exe"
```

If your CMake build output is different, set `APP_DIR` and `APP_EXE` to the actual output folder. The executable folder should include OpenCV runtime DLLs such as `opencv_world*.dll`.

Activate runtime:

```bat
call "%CONDA_ROOT%\Scripts\activate.bat" "%RUNTIME_ENV%"

set "OV_PYTHON_LIBS=%RUNTIME_ENV%\Lib\site-packages\openvino\libs"
set "OV_CONDA_BINS=%RUNTIME_ENV%\Library\bin"
set "OPENCV_BIN=C:\opencv\build\x64\vc16\bin"
set "PATH=%APP_DIR%;%OPENCV_BIN%;%OV_PYTHON_LIBS%;%OV_CONDA_BINS%;%PATH%"
```

Check:

```bat
dir "%APP_EXE%"
dir "%APP_DIR%\opencv_world*.dll"
dir "%MODEL_XML%"
dir "%VIDEO%"
```



## Run CPU

```bat
"%APP_EXE%" -m "%MODEL_XML%" -at ssd -i "%VIDEO%" -d CPU -loop
```

## Run iGPU

```bat
"%APP_EXE%" -m "%MODEL_XML%" -at ssd -i "%VIDEO%" -d GPU -loop
```

## Run NPU

```bat
"%APP_EXE%" -m "%MODEL_XML%" -at ssd -i "%VIDEO%" -d NPU -loop
```

# Result

![result](assets/object_detection.png)

Expected:

```text
The Object Detection demo window opens.
The video loops continuously.
Detected objects are shown with bounding boxes.
```

| Device | Command Option | Expected Status |
| --- | --- | --- |
| CPU | `-d CPU` | Supported |
| iGPU | `-d GPU` | Supported |
| NPU | `-d NPU` | Supported on platforms with Intel NPU support |




# Reference

* Open Model Zoo demos: https://github.com/openvinotoolkit/open_model_zoo/tree/releases/2026/1/demos
* Object Detection demo: https://github.com/openvinotoolkit/open_model_zoo/tree/releases/2026/1/demos/object_detection_demo/cpp
* Open Model Zoo model tools: https://github.com/openvinotoolkit/open_model_zoo/tree/releases/2026/1/tools/model_tools
* OpenVINO device configuration: https://docs.openvino.ai/2026/get-started/install-openvino/configurations.html
