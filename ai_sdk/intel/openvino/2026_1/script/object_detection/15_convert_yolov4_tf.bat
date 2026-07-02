@echo off
setlocal EnableExtensions

set "MODEL_NAME=yolo-v4-tf"
set "ARCH_TYPE=yolo"
set "MODEL_PRECISION=FP16"

echo.
echo ============================================================
echo  Step 15 - Convert YOLOv4-TF to OpenVINO IR
echo ============================================================
echo  OMZ runs yolo-v4-tf pre-convert first, then Model Optimizer.
echo.

call "%~dp0\05_convert_model.bat"
exit /b %errorlevel%
