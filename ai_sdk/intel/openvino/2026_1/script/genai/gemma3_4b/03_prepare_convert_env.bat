@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 3 4B - Step 03 - Prepare conversion environment
echo ============================================================
echo  Conda root : %CONDA_ROOT%
echo  Env path   : %ENV_PATH%
echo.

if not exist "%CONDA_EXE%" (
  echo [ERROR] conda.exe was not found: %CONDA_EXE%
  exit /b 1
)

set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%ENV_PATH%\Scripts;%PATH%"
set "PYTHONIOENCODING=utf-8"

if not exist "%ENV_PATH%\python.exe" (
  echo [INFO] Creating Python 3.11 environment...
  "%CONDA_EXE%" create -p "%ENV_PATH%" python=3.11 -y
  if errorlevel 1 goto :conda_error
) else (
  echo [INFO] Environment already exists. Skipping create.
)

echo [INFO] Installing packages from the OpenVINO Gemma3 notebook...
"%ENV_PATH%\python.exe" -m pip install --upgrade pip
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install "torch==2.8" "torchvision==0.23.0" "Pillow" "gradio>=4.36,<6" "opencv-python" "transformers==4.55.4" --extra-index-url https://download.pytorch.org/whl/cpu
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install -U "openvino>=2025.0.0" "openvino-tokenizers>=2025.3.0" "nncf>=2.18.0"
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install "git+https://github.com/huggingface/optimum-intel.git" --extra-index-url https://download.pytorch.org/whl/cpu
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install openvino-genai
if errorlevel 1 goto :pip_error

echo [INFO] Package check:
"%ENV_PATH%\python.exe" -c "import torch, transformers, openvino, nncf, openvino_genai; print('torch', torch.__version__); print('transformers', transformers.__version__); print('openvino', openvino.__version__); print('nncf', nncf.__version__); print('openvino_genai OK')"
if errorlevel 1 goto :pip_error

echo [OK] Conversion environment is ready.
exit /b 0

:conda_error
echo [ERROR] Failed to create the Python environment.
echo         If conda prints SafetyError but python.exe exists, rerun this script.
exit /b 1

:pip_error
echo [ERROR] Failed to install or validate packages.
exit /b 1
