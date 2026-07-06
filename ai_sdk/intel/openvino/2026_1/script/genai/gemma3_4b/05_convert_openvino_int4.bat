@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 3 4B - Step 05 - Convert raw model to OpenVINO INT4
echo ============================================================
echo  Raw model : %RAW_MODEL_PATH%
echo  Output    : %CPU_IGPU_MODEL_PATH%
echo.

if not exist "%ENV_PATH%\Scripts\optimum-cli.exe" (
  echo [ERROR] optimum-cli.exe was not found. Run 03_prepare_convert_env.bat first.
  exit /b 1
)

if not exist "%RAW_MODEL_PATH%\model.safetensors.index.json" (
  echo [ERROR] Raw model was not found. Run 04_download_raw_model.bat first.
  exit /b 1
)

set "PYTHONIOENCODING=utf-8"
set "HF_HUB_DISABLE_PROGRESS_BARS=1"
set "PATH=%ENV_PATH%\Scripts;C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%PATH%"

"%ENV_PATH%\Scripts\optimum-cli.exe" export openvino ^
  --model "%RAW_MODEL_PATH%" ^
  --task image-text-to-text ^
  "%CPU_IGPU_MODEL_PATH%" ^
  --weight-format %CONVERT_PRECISION%
if errorlevel 1 goto :convert_error

echo [OK] OpenVINO conversion finished.
exit /b 0

:convert_error
echo [ERROR] OpenVINO conversion failed.
echo         When converting from a local raw model folder, --task image-text-to-text is required.
exit /b 1
