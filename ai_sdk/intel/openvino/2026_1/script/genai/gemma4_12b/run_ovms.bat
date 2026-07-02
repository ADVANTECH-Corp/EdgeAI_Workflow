@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

set "TARGET_DEVICE=%~1"
set "MODE=%~2"
set "RUN_OVMS_EXE=%OVMS_EXE%"
if not exist "%RUN_OVMS_EXE%" if exist "%PRODUCT_OVMS_EXE%" set "RUN_OVMS_EXE=%PRODUCT_OVMS_EXE%"

echo.
echo ============================================================
echo  Gemma 4 12B - Run OVMS
echo ============================================================
echo  Device : %TARGET_DEVICE%
echo  Model  : %OV_MODEL_NAME%
echo  Path   : %OV_MODEL%
echo  OVMS   : %RUN_OVMS_EXE%
echo  Port   : %REST_PORT%
echo.

if not exist "%RUN_OVMS_EXE%" (
  echo [ERROR] ovms.exe was not found. Run 10_check_ovms.bat or update OVMS_EXE.
  exit /b 1
)

if not exist "%OV_MODEL%\openvino_language_model.xml" (
  echo [ERROR] Converted model folder is incomplete: %OV_MODEL%
  exit /b 1
)

if /i "%MODE%"=="igpu" (
  "%RUN_OVMS_EXE%" ^
    --rest_port %REST_PORT% ^
    --model_path "%OV_MODEL%" ^
    --model_name %OV_MODEL_NAME% ^
    --task text_generation ^
    --target_device %TARGET_DEVICE% ^
    --pipeline_type VLM ^
    --max_num_seqs 1 ^
    --max_num_batched_tokens 1024 ^
    --cache_size 1
) else (
  "%RUN_OVMS_EXE%" ^
    --rest_port %REST_PORT% ^
    --model_path "%OV_MODEL%" ^
    --model_name %OV_MODEL_NAME% ^
    --task text_generation ^
    --target_device %TARGET_DEVICE% ^
    --pipeline_type VLM ^
    --max_num_seqs 1 ^
    --max_num_batched_tokens 1024
)
exit /b %errorlevel%
