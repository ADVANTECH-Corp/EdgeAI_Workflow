@echo off
setlocal EnableExtensions

set "MODEL_NAME=yolo-v4-tf"
set "ARCH_TYPE=yolo"
set "MODEL_PRECISION=FP16"

echo.
echo ============================================================
echo  Step 14 - Download YOLOv4-TF model assets
echo ============================================================
echo  YOLOv4-TF downloads Darknet weights, cfg, and converter assets.
echo.

call "%~dp0\04_download_model.bat"
exit /b %errorlevel%
