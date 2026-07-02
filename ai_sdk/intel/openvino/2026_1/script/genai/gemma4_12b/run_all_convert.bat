@echo off
setlocal EnableExtensions

echo.
echo ============================================================
echo  Gemma 4 12B - Full download and conversion
echo ============================================================
echo  Warning: this requires a high-memory conversion machine and large disk space.
echo.

call "%~dp0\01_prepare_workspace.bat"
if errorlevel 1 exit /b 1

call "%~dp0\02_prepare_convert_env.bat"
if errorlevel 1 exit /b 1

call "%~dp0\03_download_raw_model.bat"
if errorlevel 1 exit /b 1

call "%~dp0\04_convert_openvino_int4.bat"
if errorlevel 1 exit /b 1

call "%~dp0\05_check_converted_model.bat"
exit /b %errorlevel%
