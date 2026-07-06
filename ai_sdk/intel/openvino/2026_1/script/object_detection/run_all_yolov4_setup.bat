@echo off
setlocal EnableExtensions

echo.
echo ============================================================
echo  OpenVINO Object Detection - YOLOv4-TF Setup
echo ============================================================
echo  This script runs workspace, env, runtime, YOLOv4 download, convert, and build.
echo.

call "%~dp0\01_prepare_workspace.bat"
if errorlevel 1 exit /b 1

call "%~dp0\02_prepare_convert_env.bat"
if errorlevel 1 exit /b 1

call "%~dp0\03_prepare_runtime_env.bat"
if errorlevel 1 exit /b 1

call "%~dp0\10_download_yolov4_tf.bat"
if errorlevel 1 exit /b 1

call "%~dp0\11_convert_yolov4_tf.bat"
if errorlevel 1 exit /b 1

call "%~dp0\06_build_demo.bat"
if errorlevel 1 exit /b 1

echo.
echo [OK] YOLOv4-TF setup finished.
echo      Run 12_run_yolov4_cpu.bat, 13_run_yolov4_igpu.bat, or 14_run_yolov4_npu.bat next.
exit /b 0
