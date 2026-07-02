@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 3 4B - Step 05 - Check model files
echo ============================================================

call :check_file "CPU / iGPU language model" "%CPU_IGPU_MODEL_PATH%\openvino_language_model.xml"
call :check_file "NPU language model" "%NPU_MODEL_PATH%\openvino_language_model.xml"

echo.
echo [INFO] Check finished.
exit /b 0

:check_file
if exist "%~2" (
  echo [OK]   %~1: %~2
) else (
  echo [MISS] %~1: %~2
)
exit /b 0
