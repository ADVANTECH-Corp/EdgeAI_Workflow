@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Step 03 - Prepare OpenVINO runtime environment
echo ============================================================
echo  Conda root : %CONDA_ROOT%
echo  Env path   : %RUNTIME_ENV%
echo.

if not exist "%CONDA_EXE%" (
  echo [ERROR] conda.exe was not found: %CONDA_EXE%
  echo         Update CONDA_ROOT in 00_config.bat.
  exit /b 1
)

if not exist "%RUNTIME_ENV%\python.exe" (
  echo [INFO] Creating Python 3.10 runtime environment...
  "%CONDA_EXE%" create -p "%RUNTIME_ENV%" python=3.10 -y
  if errorlevel 1 goto :conda_error
) else (
  echo [INFO] Runtime environment already exists. Skipping create.
)

echo [INFO] Installing OpenVINO runtime...
"%RUNTIME_ENV%\python.exe" -m pip install --upgrade pip
if errorlevel 1 goto :pip_error

"%RUNTIME_ENV%\python.exe" -m pip install openvino==2026.1.0
if errorlevel 1 goto :pip_error

echo.
echo [INFO] Package check:
"%RUNTIME_ENV%\python.exe" --version
"%RUNTIME_ENV%\python.exe" -m pip show openvino numpy

echo [OK] Runtime environment is ready.
exit /b 0

:conda_error
echo [ERROR] Failed to create the runtime environment.
echo         If conda reports SafetyError, verify whether Python was created.
exit /b 1

:pip_error
echo [ERROR] Failed to install OpenVINO runtime packages.
exit /b 1
