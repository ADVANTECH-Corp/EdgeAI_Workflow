@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Step 02 - Prepare model conversion environment
echo ============================================================
echo  Conda root : %CONDA_ROOT%
echo  Env path   : %CONVERT_ENV%
echo.

if not exist "%CONDA_EXE%" (
  echo [ERROR] conda.exe was not found: %CONDA_EXE%
  echo         Update CONDA_ROOT in 00_config.bat.
  exit /b 1
)

if not exist "%CONVERT_ENV%\python.exe" (
  echo [INFO] Creating Python 3.10 conversion environment...
  "%CONDA_EXE%" create -p "%CONVERT_ENV%" python=3.10 -y
  if errorlevel 1 goto :conda_error
) else (
  echo [INFO] Conversion environment already exists. Skipping create.
)

echo [INFO] Installing conversion packages...
"%CONVERT_ENV%\python.exe" -m pip install --upgrade pip setuptools wheel
if errorlevel 1 goto :pip_error

"%CONVERT_ENV%\python.exe" -m pip install openvino-dev==2024.6.0
if errorlevel 1 goto :pip_error

"%CONVERT_ENV%\python.exe" -m pip install tensorflow==2.15.1
if errorlevel 1 goto :pip_error

echo.
echo [INFO] Package check:
"%CONVERT_ENV%\python.exe" --version
"%CONVERT_ENV%\python.exe" -m pip show openvino-dev openvino tensorflow numpy
"%CONVERT_ENV%\Scripts\omz_downloader.exe" --help >nul
if errorlevel 1 goto :tool_error
"%CONVERT_ENV%\Scripts\omz_converter.exe" --help >nul
if errorlevel 1 goto :tool_error

echo [OK] Conversion environment is ready.
exit /b 0

:conda_error
echo [ERROR] Failed to create the conversion environment.
echo         If conda reports SafetyError, verify whether Python was created.
exit /b 1

:pip_error
echo [ERROR] Failed to install conversion packages.
exit /b 1

:tool_error
echo [ERROR] OMZ tools were not found in the conversion environment.
exit /b 1
