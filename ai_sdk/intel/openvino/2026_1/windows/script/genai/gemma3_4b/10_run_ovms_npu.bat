@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo Note: NPU execution requires Intel NPU hardware, driver support, and the channel-wise INT4 model.
call "%~dp0\run_ovms.bat" NPU "%NPU_MODEL_PATH%" "%NPU_MODEL_NAME%" npu
exit /b %errorlevel%
