@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 3 4B - Environment Check
echo ============================================================

call :check_file "Conda" "%CONDA_EXE%"
call :check_file "Python env" "%ENV_PATH%\python.exe"
call :check_dir "Workspace" "%WORKSPACE%"
call :check_dir "Model root" "%MODEL_ROOT%"
call :check_file "CPU / iGPU model" "%CPU_IGPU_MODEL_PATH%\openvino_language_model.xml"
call :check_file "NPU model" "%NPU_MODEL_PATH%\openvino_language_model.xml"
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
