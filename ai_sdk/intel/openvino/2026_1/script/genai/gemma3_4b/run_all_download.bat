@echo off
setlocal EnableExtensions

echo.
echo ============================================================
echo  Gemma 3 4B - Download all prepared OpenVINO models
echo ============================================================

call "%~dp0\01_prepare_workspace.bat"
if errorlevel 1 exit /b 1

call "%~dp0\02_prepare_env.bat"
if errorlevel 1 exit /b 1

call "%~dp0\03_download_cpu_igpu_model.bat"
if errorlevel 1 exit /b 1

call "%~dp0\04_download_npu_model.bat"
if errorlevel 1 exit /b 1

call "%~dp0\05_check_models.bat"
exit /b %errorlevel%
