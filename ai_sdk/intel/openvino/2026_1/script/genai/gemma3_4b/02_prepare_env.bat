@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 3 4B - Step 02 - Prepare Python environment
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

echo [INFO] Installing packages...
"%ENV_PATH%\python.exe" -m pip install --upgrade pip
if errorlevel 1 goto :pip_error

"%ENV_PATH%\python.exe" -m pip install openvino==2026.1.0 openvino-genai==2026.1.0.0 huggingface_hub requests
if errorlevel 1 goto :pip_error

echo [INFO] Package check:
"%ENV_PATH%\python.exe" -c "import openvino, openvino_genai; print(openvino.__version__); print('openvino_genai OK')"
if errorlevel 1 goto :pip_error

echo [OK] Python environment is ready.
exit /b 0

:conda_error
echo [ERROR] Failed to create the Python environment.
echo         If conda reports SafetyError, verify whether Python was created.
exit /b 1

:pip_error
echo [ERROR] Failed to install or validate packages.
exit /b 1
