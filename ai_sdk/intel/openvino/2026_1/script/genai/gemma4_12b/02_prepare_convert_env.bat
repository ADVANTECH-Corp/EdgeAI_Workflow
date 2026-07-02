@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 4 12B - Step 02 - Prepare conversion environment
echo ============================================================
echo  Conda root : %CONDA_ROOT%
echo  Env path   : %ENV_PATH%
echo.

if not exist "%CONDA_EXE%" (
  echo [ERROR] conda.exe was not found: %CONDA_EXE%
  exit /b 1
)

if not exist "%ENV_PATH%\python.exe" (
  echo [INFO] Creating Python 3.11 environment...
  "%CONDA_EXE%" create -p "%ENV_PATH%" python=3.11 -y
  if errorlevel 1 goto :conda_error
) else (
  echo [INFO] Environment already exists. Skipping create.
)

echo [INFO] Installing conversion packages. This can take several minutes...
"%ENV_PATH%\python.exe" -m pip install --upgrade pip
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install transformers==5.12.1 optimum==2.2.0 openvino==2026.1.0 openvino-genai==2026.1.0.0 nncf accelerate huggingface_hub safetensors pillow sentencepiece protobuf requests
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install --upgrade --no-deps git+https://github.com/huggingface/optimum-intel.git
if errorlevel 1 goto :pip_error

echo [INFO] Package check:
"%ENV_PATH%\python.exe" -c "import transformers, openvino, openvino_genai; import importlib.metadata as m; print(transformers.__version__); print(openvino.__version__); print(m.version('optimum-intel'))"
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
