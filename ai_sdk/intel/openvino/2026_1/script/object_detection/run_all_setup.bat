@echo off
setlocal EnableExtensions

echo.
echo ============================================================
echo  OpenVINO Object Detection - Full Setup
echo ============================================================
echo  This script runs steps 01 through 06.
echo.

call "%~dp0\01_prepare_workspace.bat"
if errorlevel 1 exit /b 1

call "%~dp0\02_prepare_convert_env.bat"
if errorlevel 1 exit /b 1

call "%~dp0\03_prepare_runtime_env.bat"
if errorlevel 1 exit /b 1

call "%~dp0\04_download_model.bat"
if errorlevel 1 exit /b 1

call "%~dp0\05_convert_model.bat"
if errorlevel 1 exit /b 1

call "%~dp0\06_build_demo.bat"
if errorlevel 1 exit /b 1

echo.
echo [OK] Full setup finished.
echo      Run 07_run_cpu.bat, 08_run_igpu.bat, or 09_run_npu.bat next.
exit /b 0
