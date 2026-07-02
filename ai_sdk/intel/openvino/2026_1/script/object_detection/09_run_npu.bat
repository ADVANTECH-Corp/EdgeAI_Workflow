@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Run Object Detection - NPU
echo ============================================================
echo  Note: NPU execution requires Intel NPU hardware and driver support.
echo.
call "%~dp0\run_demo.bat" NPU
exit /b %errorlevel%
