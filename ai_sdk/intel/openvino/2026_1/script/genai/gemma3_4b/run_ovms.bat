@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

set "TARGET_DEVICE=%~1"
set "MODEL_PATH=%~2"
set "MODEL_NAME=%~3"
set "MODE=%~4"

set "RUN_OVMS_EXE=%OVMS_EXE%"
if not exist "%RUN_OVMS_EXE%" if exist "%PRODUCT_OVMS_EXE%" set "RUN_OVMS_EXE=%PRODUCT_OVMS_EXE%"

echo.
echo ============================================================
echo  Gemma 3 4B - Run OVMS
echo ============================================================
echo  Device : %TARGET_DEVICE%
echo  Model  : %MODEL_NAME%
echo  Path   : %MODEL_PATH%
echo  OVMS   : %RUN_OVMS_EXE%
echo  Port   : %REST_PORT%
echo.

if not exist "%RUN_OVMS_EXE%" (
  echo [ERROR] ovms.exe was not found. Run 10_check_ovms.bat or update OVMS_EXE.
  exit /b 1
)

if not exist "%MODEL_PATH%\openvino_language_model.xml" (
  echo [ERROR] Model folder is incomplete: %MODEL_PATH%
  exit /b 1
)

if /i "%MODE%"=="npu" (
  "%RUN_OVMS_EXE%" ^
    --rest_port %REST_PORT% ^
    --model_path "%MODEL_PATH%" ^
    --model_name %MODEL_NAME% ^
    --task text_generation ^
    --target_device %TARGET_DEVICE% ^
    --pipeline_type VLM ^
    --max_num_seqs 1 ^
    --max_num_batched_tokens 1024 ^
    --max_prompt_len 2048 ^
    --cache_size 0 ^
    --enable_prefix_caching false
) else (
  "%RUN_OVMS_EXE%" ^
    --rest_port %REST_PORT% ^
    --model_path "%MODEL_PATH%" ^
    --model_name %MODEL_NAME% ^
    --task text_generation ^
    --target_device %TARGET_DEVICE% ^
    --pipeline_type VLM ^
    --max_num_seqs 1 ^
    --max_num_batched_tokens 1024
)
exit /b %errorlevel%
