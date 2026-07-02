@echo off
setlocal EnableExtensions

REM Common configuration for Gemma 3 4B OpenVINO / OVMS workflow.
REM Edit this file when your installation paths are different.

if not defined CONDA_ROOT set "CONDA_ROOT=C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3"
if not defined WORKSPACE set "WORKSPACE=C:\Advantech\GenAI"
if not defined ENV_PATH set "ENV_PATH=%WORKSPACE%\envs\ovms-vlm"
if not defined MODEL_ROOT set "MODEL_ROOT=%WORKSPACE%\models"
if not defined REST_PORT set "REST_PORT=23953"

if not defined CPU_IGPU_MODEL_NAME set "CPU_IGPU_MODEL_NAME=gemma-3-4b-it-int4"
if not defined NPU_MODEL_NAME set "NPU_MODEL_NAME=gemma-3-4b-it-int4-cw-ov"
if not defined CPU_IGPU_REPO_ID set "CPU_IGPU_REPO_ID=Advantech-EIOT/intel_google-gemma-3-4b-it-int4"
if not defined NPU_REPO_ID set "NPU_REPO_ID=Advantech-EIOT/intel_google-gemma-3-4b-it-int4-cw-ov"

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..\..") do set "GUIDE_ROOT=%%~fI"
if not defined OVMS_EXE set "OVMS_EXE=%WORKSPACE%\ovms\ovms.exe"
if not defined PRODUCT_OVMS_EXE set "PRODUCT_OVMS_EXE=C:\Program Files\Advantech\EdgeAI\System\Intel\GenAI\app\engine\intel\scripts\ovms_2026_2\ovms.exe"

set "CONDA_EXE=%CONDA_ROOT%\Scripts\conda.exe"
set "CPU_IGPU_MODEL_PATH=%MODEL_ROOT%\%CPU_IGPU_MODEL_NAME%"
set "NPU_MODEL_PATH=%MODEL_ROOT%\%NPU_MODEL_NAME%"
set "CHAT_URL=http://127.0.0.1:%REST_PORT%/v3/chat/completions"
set "CHAT_PROMPT=Answer in one sentence: what is OpenVINO?"

endlocal & (
  set "CONDA_ROOT=%CONDA_ROOT%"
  set "WORKSPACE=%WORKSPACE%"
  set "ENV_PATH=%ENV_PATH%"
  set "MODEL_ROOT=%MODEL_ROOT%"
  set "REST_PORT=%REST_PORT%"
  set "CPU_IGPU_MODEL_NAME=%CPU_IGPU_MODEL_NAME%"
  set "NPU_MODEL_NAME=%NPU_MODEL_NAME%"
  set "CPU_IGPU_REPO_ID=%CPU_IGPU_REPO_ID%"
  set "NPU_REPO_ID=%NPU_REPO_ID%"
  set "SCRIPT_DIR=%SCRIPT_DIR%"
  set "GUIDE_ROOT=%GUIDE_ROOT%"
  set "OVMS_EXE=%OVMS_EXE%"
  set "PRODUCT_OVMS_EXE=%PRODUCT_OVMS_EXE%"
  set "CONDA_EXE=%CONDA_EXE%"
  set "CPU_IGPU_MODEL_PATH=%CPU_IGPU_MODEL_PATH%"
  set "NPU_MODEL_PATH=%NPU_MODEL_PATH%"
  set "CHAT_URL=%CHAT_URL%"
  set "CHAT_PROMPT=%CHAT_PROMPT%"
)
