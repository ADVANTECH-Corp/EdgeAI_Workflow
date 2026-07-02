@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 4 12B - Environment Check
echo ============================================================

call :check_file "Conda" "%CONDA_EXE%"
call :check_file "Python env" "%ENV_PATH%\python.exe"
call :check_dir "Workspace" "%WORKSPACE%"
call :check_dir "Model workspace" "%MODEL_WORKSPACE%"
call :check_file "Raw model config" "%RAW_MODEL%\config.json"
call :check_file "Converted language model" "%OV_MODEL%\openvino_language_model.xml"
call :check_file "OVMS" "%OVMS_EXE%"
call :check_file "Product OVMS" "%PRODUCT_OVMS_EXE%"

if defined HF_TOKEN (
  echo [OK]   HF_TOKEN is set.
) else (
  echo [INFO] HF_TOKEN is not set. Use huggingface-cli login or set HF_TOKEN for gated repos.
)

echo.
echo [INFO] Check finished.
exit /b 0

:check_file
if exist "%~2" (echo [OK]   %~1: %~2) else (echo [MISS] %~1: %~2)
exit /b 0

:check_dir
if exist "%~2\" (echo [OK]   %~1: %~2) else (echo [MISS] %~1: %~2)
exit /b 0
