@echo off
setlocal EnableExtensions

set "MODEL_NAME=yolo-v4-tf"
set "ARCH_TYPE=yolo"
set "MODEL_PRECISION=FP16"

echo.
echo ============================================================
echo  Run YOLOv4-TF Object Detection - NPU
echo ============================================================
echo  Note: NPU execution requires Intel NPU hardware and driver support.
echo.
call "%~dp0\run_demo.bat" NPU
exit /b %errorlevel%
