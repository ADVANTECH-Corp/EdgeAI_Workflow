@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 4 - Step 03 - Download raw Hugging Face model
echo ============================================================
echo  Model ID : %MODEL_ID%
echo  Output   : %RAW_MODEL%
echo.
echo  This download is large. Confirm disk space before running.
echo.

if not exist "%ENV_PATH%\python.exe" (
  echo [ERROR] Python environment was not found. Run 03_prepare_convert_env.bat first.
  exit /b 1
)

set "PYTHONIOENCODING=utf-8"
if not exist "%MODEL_WORKSPACE%" mkdir "%MODEL_WORKSPACE%"

pushd "%GUIDE_ROOT%"
"%ENV_PATH%\python.exe" script\download_model.py ^
  --repo-id %MODEL_ID% ^
  --output "%RAW_MODEL%"
if errorlevel 1 goto :pop_error
popd

echo [OK] Raw model download finished.
exit /b 0

:pop_error
popd
echo [ERROR] Raw model download failed.
echo         If the repo is gated, login with:
echo         "%ENV_PATH%\Scripts\hf.exe" auth login
echo         Or set HF_TOKEN in the same Command Prompt.
exit /b 1
