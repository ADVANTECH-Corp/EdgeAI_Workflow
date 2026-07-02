@echo off
setlocal EnableExtensions

REM Common configuration for Gemma 4 12B conversion and OVMS workflow.
REM Gemma 4 12B conversion requires a high-memory machine.

if not defined CONDA_ROOT set "CONDA_ROOT=C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3"
if not defined WORKSPACE set "WORKSPACE=C:\Advantech\GenAI"
if not defined ENV_PATH set "ENV_PATH=%WORKSPACE%\envs\gemma4_12b_convert"
if not defined MODEL_ID set "MODEL_ID=google/gemma-4-12B-it"
if not defined MODEL_WORKSPACE set "MODEL_WORKSPACE=%WORKSPACE%\models\gemma4_12b_from_scratch"
if not defined RAW_MODEL set "RAW_MODEL=%MODEL_WORKSPACE%\raw_model"
if not defined OV_MODEL set "OV_MODEL=%MODEL_WORKSPACE%\openvino_int4"
if not defined OV_MODEL_NAME set "OV_MODEL_NAME=gemma-4-12b-it-int4"
if not defined REST_PORT set "REST_PORT=23953"

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..\..") do set "GUIDE_ROOT=%%~fI"
if not defined OVMS_EXE set "OVMS_EXE=%WORKSPACE%\ovms\ovms.exe"
if not defined PRODUCT_OVMS_EXE set "PRODUCT_OVMS_EXE=C:\Program Files\Advantech\EdgeAI\System\Intel\GenAI\app\engine\intel\scripts\ovms_2026_2\ovms.exe"

set "CONDA_EXE=%CONDA_ROOT%\Scripts\conda.exe"
set "CHAT_URL=http://127.0.0.1:%REST_PORT%/v3/chat/completions"
set "CHAT_PROMPT=Answer in one sentence: what is OpenVINO?"

endlocal & (
  set "CONDA_ROOT=%CONDA_ROOT%"
  set "WORKSPACE=%WORKSPACE%"
  set "ENV_PATH=%ENV_PATH%"
  set "MODEL_ID=%MODEL_ID%"
  set "MODEL_WORKSPACE=%MODEL_WORKSPACE%"
  set "RAW_MODEL=%RAW_MODEL%"
  set "OV_MODEL=%OV_MODEL%"
  set "OV_MODEL_NAME=%OV_MODEL_NAME%"
  set "REST_PORT=%REST_PORT%"
  set "SCRIPT_DIR=%SCRIPT_DIR%"
  set "GUIDE_ROOT=%GUIDE_ROOT%"
  set "OVMS_EXE=%OVMS_EXE%"
  set "PRODUCT_OVMS_EXE=%PRODUCT_OVMS_EXE%"
  set "CONDA_EXE=%CONDA_EXE%"
  set "CHAT_URL=%CHAT_URL%"
  set "CHAT_PROMPT=%CHAT_PROMPT%"
)
