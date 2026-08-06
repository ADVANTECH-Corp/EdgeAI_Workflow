@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

set "TARGET_DEVICE=%~1"
if "%TARGET_DEVICE%"=="" set "TARGET_DEVICE=CPU"

set "RUN_APP_EXE=%APP_EXE%"
if not exist "%RUN_APP_EXE%" if exist "%PRODUCT_APP_EXE%" set "RUN_APP_EXE=%PRODUCT_APP_EXE%"

for %%I in ("%RUN_APP_EXE%") do set "RUN_APP_DIR=%%~dpI"

echo  Device     : %TARGET_DEVICE%
echo  App        : %RUN_APP_EXE%
echo  Model      : %MODEL_XML%
echo  Arch type  : %ARCH_TYPE%
echo  Video      : %VIDEO%
if defined LABELS_FILE echo  Labels     : %LABELS_FILE%
echo.

if not exist "%RUN_APP_EXE%" (
  echo [ERROR] object_detection_demo.exe was not found.
  echo         Run 06_build_demo.bat or install the Advantech product app.
  exit /b 1
)

if not exist "%MODEL_XML%" (
  echo [ERROR] Model XML was not found.
  echo         Run 05_convert_model.bat first.
  exit /b 1
)

if not exist "%VIDEO%" (
  echo [ERROR] Demo video was not found.
  echo         Update EDGEAI_WORKFLOW or VIDEO in 00_config.bat.
  exit /b 1
)

if not exist "%CONDA_ACTIVATE%" (
  echo [ERROR] Conda activate script was not found: %CONDA_ACTIVATE%
  exit /b 1
)

call "%CONDA_ACTIVATE%" "%RUNTIME_ENV%"
if errorlevel 1 exit /b 1

set "PATH=%RUN_APP_DIR%;%OPENCV_BIN%;%OV_PYTHON_LIBS%;%OV_CONDA_BINS%;%PATH%"

if defined LABELS_FILE if exist "%LABELS_FILE%" (
  "%RUN_APP_EXE%" -m "%MODEL_XML%" -at %ARCH_TYPE% -i "%VIDEO%" -d %TARGET_DEVICE% -labels "%LABELS_FILE%" -loop
) else (
  "%RUN_APP_EXE%" -m "%MODEL_XML%" -at %ARCH_TYPE% -i "%VIDEO%" -d %TARGET_DEVICE% -loop
)
exit /b %errorlevel%
