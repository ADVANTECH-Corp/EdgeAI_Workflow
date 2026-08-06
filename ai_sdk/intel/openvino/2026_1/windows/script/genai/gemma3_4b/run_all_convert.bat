@echo off
setlocal EnableExtensions

call "%~dp0\01_check_env.bat"
if errorlevel 1 exit /b 1

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
