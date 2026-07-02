@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Step 05 - Convert model to OpenVINO IR
echo ============================================================
echo  Model name : %MODEL_NAME%
echo  Output XML : %MODEL_XML%
echo  Arch type  : %ARCH_TYPE%
echo.

if not exist "%CONVERT_ENV%\Scripts\omz_converter.exe" (
  echo [ERROR] omz_converter.exe was not found.
  echo         Run 02_prepare_convert_env.bat first.
  exit /b 1
)

if not exist "%OMZ_DIR%\models\public" (
  echo [ERROR] Open Model Zoo was not found: %OMZ_DIR%
  echo         Run 04_download_model.bat first.
  exit /b 1
)

pushd "%OMZ_DIR%\models\public"
echo [INFO] Running omz_converter...
"%CONVERT_ENV%\Scripts\omz_converter.exe" ^
  --name %MODEL_NAME% ^
  --download_dir "%MODEL_ROOT%" ^
  --output_dir "%MODEL_ROOT%" ^
  --mo "%CONVERT_ENV%\Scripts\mo.exe"
if errorlevel 1 goto :pop_error
popd

if not exist "%MODEL_XML%" (
  echo [ERROR] Converted model XML was not found:
  echo         %MODEL_XML%
  exit /b 1
)

if not exist "%MODEL_BIN%" (
  echo [ERROR] Converted model BIN was not found:
  echo         %MODEL_BIN%
  exit /b 1
)

echo [OK] Model conversion finished.
exit /b 0

:pop_error
popd
echo [ERROR] Model conversion failed.
exit /b 1
