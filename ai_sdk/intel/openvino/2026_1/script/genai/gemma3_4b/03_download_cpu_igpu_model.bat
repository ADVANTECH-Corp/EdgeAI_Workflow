@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 3 4B - Step 03 - Download CPU / iGPU model
echo ============================================================
echo  Repo   : %CPU_IGPU_REPO_ID%
echo  Output : %CPU_IGPU_MODEL_PATH%
echo.

if not exist "%ENV_PATH%\python.exe" (
  echo [ERROR] Python environment was not found. Run 02_prepare_env.bat first.
  exit /b 1
)

if not exist "%MODEL_ROOT%" mkdir "%MODEL_ROOT%"

pushd "%GUIDE_ROOT%"
"%ENV_PATH%\python.exe" script\download_model.py ^
  --repo-id %CPU_IGPU_REPO_ID% ^
  --output "%CPU_IGPU_MODEL_PATH%"
if errorlevel 1 goto :pop_error
popd

echo [OK] CPU / iGPU model download finished.
exit /b 0

:pop_error
popd
echo [ERROR] CPU / iGPU model download failed.
echo         If the repo is gated, login with huggingface-cli or set HF_TOKEN.
exit /b 1
