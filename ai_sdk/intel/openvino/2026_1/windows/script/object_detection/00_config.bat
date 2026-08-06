@echo off
setlocal EnableExtensions

REM Common configuration for the OpenVINO object detection workflow.
REM Edit this file when your installation paths are different.

if not defined CONDA_ROOT set "CONDA_ROOT=C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3"
if not defined WORKSPACE set "WORKSPACE=C:\Advantech\VisionAI"
if not defined MODEL_NAME set "MODEL_NAME=ssd_mobilenet_v1_coco"
if not defined ARCH_TYPE set "ARCH_TYPE=ssd"
if not defined MODEL_PRECISION set "MODEL_PRECISION=FP16"
if defined OPENCV_PATH if not defined OPENCV_DIR set "OPENCV_DIR=%OPENCV_PATH%"
if not defined OPENCV_DIR set "OPENCV_DIR=C:\opencv\build"
if not defined CMAKE_ARCH set "CMAKE_ARCH=x64"
if not defined CMAKE_TOOLSET set "CMAKE_TOOLSET=host=x64"

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "GUIDE_ROOT=%%~fI"
for %%I in ("%GUIDE_ROOT%\..\..\..\..") do set "REPO_ROOT=%%~fI"

if not defined MODEL_ROOT set "MODEL_ROOT=%WORKSPACE%\models"
if not defined CONVERT_ENV set "CONVERT_ENV=%WORKSPACE%\envs\omz-py310"
if not defined RUNTIME_ENV set "RUNTIME_ENV=%WORKSPACE%\envs\vision-runtime-py310"
if not defined OMZ_DIR set "OMZ_DIR=%WORKSPACE%\open_model_zoo"
if not defined BUILD_DIR set "BUILD_DIR=%WORKSPACE%\build\omz_demos_build"
if not defined APP_DIR set "APP_DIR=%BUILD_DIR%\intel64\Release"
if not defined APP_EXE set "APP_EXE=%APP_DIR%\object_detection_demo.exe"
if not defined PRODUCT_APP_EXE set "PRODUCT_APP_EXE=C:\Program Files\Advantech\EdgeAI\System\Intel\VisionAI\app\object_detection\object_detection_demo.exe"
if not defined EDGEAI_WORKFLOW set "EDGEAI_WORKFLOW=%REPO_ROOT%"
if not defined VIDEO set "VIDEO=%EDGEAI_WORKFLOW%\data\video\ObjectDetection.mp4"

if not exist "%OPENCV_DIR%\" (
  for %%I in ("C:\opencv\build" "C:\opencv\opencv\build" "C:\OpenCV\build" "C:\tools\opencv\build") do (
    if not defined OPENCV_DIR_FOUND if exist "%%~I\" set "OPENCV_DIR_FOUND=%%~I"
  )
  if defined OPENCV_DIR_FOUND set "OPENCV_DIR=%OPENCV_DIR_FOUND%"
)

if not defined GIT_EXE (
  for /f "delims=" %%I in ('where git.exe 2^>nul') do if not defined GIT_EXE set "GIT_EXE=%%I"
)
if not defined GIT_EXE (
  for %%I in ("C:\Program Files\Git\cmd\git.exe" "C:\Program Files\Git\bin\git.exe" "C:\Program Files (x86)\Git\cmd\git.exe" "C:\Program Files (x86)\Git\bin\git.exe") do (
    if not defined GIT_EXE if exist "%%~I" set "GIT_EXE=%%~I"
  )
)
if defined GIT_EXE for %%I in ("%GIT_EXE%") do set "PATH=%%~dpI;%PATH%"

if not defined CMAKE_EXE (
  for /f "delims=" %%I in ('where cmake.exe 2^>nul') do if not defined CMAKE_EXE set "CMAKE_EXE=%%I"
)
if not defined CMAKE_EXE (
  for %%I in ("C:\Program Files\CMake\bin\cmake.exe" "C:\Program Files (x86)\CMake\bin\cmake.exe" "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe") do (
    if not defined CMAKE_EXE if exist "%%~I" set "CMAKE_EXE=%%~I"
  )
)
if defined CMAKE_EXE for %%I in ("%CMAKE_EXE%") do set "PATH=%%~dpI;%PATH%"

if not defined VSWHERE_EXE (
  if exist "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" set "VSWHERE_EXE=C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
)
if not defined VSINSTALL_DIR if defined VSWHERE_EXE (
  for /f "usebackq delims=" %%I in (`"%VSWHERE_EXE%" -latest -products * -property installationPath 2^>nul`) do if not defined VSINSTALL_DIR set "VSINSTALL_DIR=%%I"
)
if not defined VSDEVCMD (
  if defined VSINSTALL_DIR if exist "%VSINSTALL_DIR%\Common7\Tools\VsDevCmd.bat" set "VSDEVCMD=%VSINSTALL_DIR%\Common7\Tools\VsDevCmd.bat"
)
if not defined VSDEVCMD (
  for %%I in ("C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\Common7\Tools\VsDevCmd.bat" "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat" "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat") do (
    if not defined VSDEVCMD if exist "%%~I" set "VSDEVCMD=%%~I"
  )
)
if not defined CMAKE_GENERATOR (
  if exist "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\Common7\Tools\VsDevCmd.bat" (
    set "CMAKE_GENERATOR=Visual Studio 18 2026"
  ) else (
    set "CMAKE_GENERATOR=Visual Studio 17 2022"
  )
)

if not defined OPENCV_BIN set "OPENCV_BIN=%OPENCV_DIR%\x64\vc16\bin"
set "CONDA_EXE=%CONDA_ROOT%\Scripts\conda.exe"
set "CONDA_ACTIVATE=%CONDA_ROOT%\Scripts\activate.bat"
set "MODEL_XML=%MODEL_ROOT%\public\%MODEL_NAME%\%MODEL_PRECISION%\%MODEL_NAME%.xml"
set "MODEL_BIN=%MODEL_ROOT%\public\%MODEL_NAME%\%MODEL_PRECISION%\%MODEL_NAME%.bin"
if not defined LABELS_FILE if exist "%OMZ_DIR%\data\dataset_classes\coco_80cl.txt" set "LABELS_FILE=%OMZ_DIR%\data\dataset_classes\coco_80cl.txt"
set "OV_PYTHON_LIBS=%RUNTIME_ENV%\Lib\site-packages\openvino\libs"
set "OV_CONDA_BINS=%RUNTIME_ENV%\Library\bin"
set "OPENVINO_CMAKE_DIR=%RUNTIME_ENV%\Lib\site-packages\openvino\cmake"

endlocal & (
  set "CONDA_ROOT=%CONDA_ROOT%"
  set "WORKSPACE=%WORKSPACE%"
  set "MODEL_NAME=%MODEL_NAME%"
  set "ARCH_TYPE=%ARCH_TYPE%"
  set "MODEL_PRECISION=%MODEL_PRECISION%"
  set "OPENCV_DIR=%OPENCV_DIR%"
  set "CMAKE_GENERATOR=%CMAKE_GENERATOR%"
  set "CMAKE_ARCH=%CMAKE_ARCH%"
  set "CMAKE_TOOLSET=%CMAKE_TOOLSET%"
  set "GIT_EXE=%GIT_EXE%"
  set "CMAKE_EXE=%CMAKE_EXE%"
  set "VSWHERE_EXE=%VSWHERE_EXE%"
  set "VSINSTALL_DIR=%VSINSTALL_DIR%"
  set "VSDEVCMD=%VSDEVCMD%"
  set "PATH=%PATH%"
  set "SCRIPT_DIR=%SCRIPT_DIR%"
  set "GUIDE_ROOT=%GUIDE_ROOT%"
  set "REPO_ROOT=%REPO_ROOT%"
  set "MODEL_ROOT=%MODEL_ROOT%"
  set "CONVERT_ENV=%CONVERT_ENV%"
  set "RUNTIME_ENV=%RUNTIME_ENV%"
  set "OMZ_DIR=%OMZ_DIR%"
  set "BUILD_DIR=%BUILD_DIR%"
  set "APP_DIR=%APP_DIR%"
  set "APP_EXE=%APP_EXE%"
  set "PRODUCT_APP_EXE=%PRODUCT_APP_EXE%"
  set "OPENCV_BIN=%OPENCV_BIN%"
  set "EDGEAI_WORKFLOW=%EDGEAI_WORKFLOW%"
  set "VIDEO=%VIDEO%"
  set "CONDA_EXE=%CONDA_EXE%"
  set "CONDA_ACTIVATE=%CONDA_ACTIVATE%"
  set "MODEL_XML=%MODEL_XML%"
  set "MODEL_BIN=%MODEL_BIN%"
  set "LABELS_FILE=%LABELS_FILE%"
  set "OV_PYTHON_LIBS=%OV_PYTHON_LIBS%"
  set "OV_CONDA_BINS=%OV_CONDA_BINS%"
  set "OPENVINO_CMAKE_DIR=%OPENVINO_CMAKE_DIR%"
)
