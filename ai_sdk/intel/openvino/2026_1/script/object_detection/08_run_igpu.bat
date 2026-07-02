@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Run Object Detection - iGPU
echo ============================================================
call "%~dp0\run_demo.bat" GPU
exit /b %errorlevel%
