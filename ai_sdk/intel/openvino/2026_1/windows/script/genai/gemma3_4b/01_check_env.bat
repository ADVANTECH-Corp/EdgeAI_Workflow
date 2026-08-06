@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 3 4B - Step 01 - Check environment
echo ============================================================

call :check_file "EdgeAI SDK conda" "%CONDA_EXE%"
call :check_file "Git" "C:\Program Files\Git\cmd\git.exe"
call :check_file "Python env" "%ENV_PATH%\python.exe"
call :check_dir "Workspace" "%WORKSPACE%"
call :check_dir "Model root" "%MODEL_ROOT%"
call :check_file "Raw Gemma3 model" "%RAW_MODEL_PATH%\model.safetensors.index.json"
call :check_file "Converted CPU / iGPU model" "%CPU_IGPU_MODEL_PATH%\openvino_language_model.xml"
call :check_file "NPU prepared model" "%NPU_MODEL_PATH%\openvino_language_model.xml"
call :check_file "OVMS" "%OVMS_EXE%"
call :check_file "Product OVMS" "%PRODUCT_OVMS_EXE%"

echo.
echo [INFO] If Git is missing, install Git for Windows and select the PATH option:
echo        https://git-scm.com/download/win
echo [INFO] If Hugging Face access fails, accept the model license first:
echo        https://huggingface.co/google/gemma-3-4b-it
echo.
echo [INFO] Check finished.
exit /b 0

:check_file
if exist "%~2" (echo [OK]   %~1: %~2) else (echo [MISS] %~1: %~2)
exit /b 0

:check_dir
if exist "%~2\" (echo [OK]   %~1: %~2) else (echo [MISS] %~1: %~2)
exit /b 0
