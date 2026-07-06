@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 4 - Step 02 - Prepare official conversion environment
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

where git.exe >nul 2>nul
if errorlevel 1 (
  echo [ERROR] git.exe was not found in PATH.
  echo         Install Git for Windows and select the PATH option:
  echo         https://git-scm.com/download/win
  exit /b 1
)

if not exist "%ENV_PATH%\python.exe" (
  echo [INFO] Creating Python 3.11 environment...
  "%CONDA_EXE%" create -p "%ENV_PATH%" python=3.11 -y
  if errorlevel 1 goto :conda_error
) else (
  echo [INFO] Environment already exists. Skipping create.
)

echo [INFO] Installing official Gemma4 notebook packages. This can take several minutes...
"%ENV_PATH%\python.exe" -m pip install --upgrade pip
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install "git+https://github.com/huggingface/optimum-intel.git" --extra-index-url https://download.pytorch.org/whl/cpu
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install -U --pre "openvino-genai" "openvino" "openvino-tokenizers" "nncf" --extra-index-url https://storage.openvinotoolkit.org/simple/wheels/nightly
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install "transformers==5.5.0"
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install "torch>=2.10" "torchvision" "Pillow" "gradio>=6.0" "opencv-python" "requests" "matplotlib" --extra-index-url https://download.pytorch.org/whl/cpu
if errorlevel 1 goto :pip_error

echo [INFO] Package check:
"%ENV_PATH%\python.exe" -c "import torch, transformers, openvino, openvino_genai, nncf; import importlib.metadata as m; print('torch', torch.__version__); print('transformers', transformers.__version__); print('openvino', openvino.__version__); print('openvino_genai OK'); print('nncf', nncf.__version__); print('optimum-intel', m.version('optimum-intel')); print('optimum', m.version('optimum'))"
if errorlevel 1 goto :pip_error

echo [OK] Conversion environment is ready.
exit /b 0

:conda_error
echo [ERROR] Failed to create the conversion environment.
echo         If conda reports SafetyError, verify whether Python was created.
exit /b 1

:pip_error
echo [ERROR] Failed to install or validate conversion packages.
exit /b 1
