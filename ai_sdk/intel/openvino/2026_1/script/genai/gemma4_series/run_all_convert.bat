@echo off
setlocal EnableExtensions

echo.
echo ============================================================
echo  Gemma 4 - Full download and conversion
echo ============================================================
echo  Default model: google/gemma-4-E2B-it
echo  Larger Gemma 4 models require more memory, disk, and time.
echo.

call "%~dp0\02_prepare_workspace.bat"
if errorlevel 1 exit /b 1

call "%~dp0\03_prepare_convert_env.bat"
if errorlevel 1 exit /b 1

call "%~dp0\04_download_raw_model.bat"
if errorlevel 1 exit /b 1

call "%~dp0\05_convert_openvino_int4.bat"
if errorlevel 1 exit /b 1

call "%~dp0\06_check_converted_model.bat"
exit /b %errorlevel%
