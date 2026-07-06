@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 4 - Step 04 - Convert to OpenVINO INT4
echo ============================================================
echo  Raw model : %RAW_MODEL%
echo  Output    : %OV_MODEL%
echo.
echo  Method    : official Gemma4 notebook optimum-cli export
echo.

if not exist "%ENV_PATH%\Scripts\optimum-cli.exe" (
  echo [ERROR] optimum-cli.exe was not found. Run 02_prepare_convert_env.bat first.
  exit /b 1
)

if not exist "%RAW_MODEL%\config.json" (
  echo [ERROR] Raw model folder is incomplete: %RAW_MODEL%
  echo         Run 03_download_raw_model.bat first.
  exit /b 1
)

set "PYTHONIOENCODING=utf-8"
set "PATH=%ENV_PATH%\Scripts;C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%PATH%"

"%ENV_PATH%\Scripts\optimum-cli.exe" export openvino ^
  --model "%RAW_MODEL%" ^
  --task image-text-to-text ^
  "%OV_MODEL%" ^
  --weight-format int4
if errorlevel 1 goto :convert_error

echo [OK] OpenVINO INT4 conversion finished.
exit /b 0

:convert_error
echo [ERROR] OpenVINO conversion failed.
echo         The validated flow requires the official Gemma4 notebook environment:
echo         transformers==5.5.0 and OpenVINO nightly/pre-release packages.
exit /b 1
