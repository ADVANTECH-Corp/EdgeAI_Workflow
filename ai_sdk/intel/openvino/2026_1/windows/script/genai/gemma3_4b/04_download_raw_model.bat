@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Gemma 3 4B - Step 04 - Download raw Hugging Face model
echo ============================================================
echo  Repo   : %RAW_MODEL_ID%
echo  Output : %RAW_MODEL_PATH%
echo.

if not exist "%ENV_PATH%\python.exe" (
  echo [ERROR] Python environment was not found. Run 03_prepare_convert_env.bat first.
  exit /b 1
)

if not exist "%MODEL_ROOT%" mkdir "%MODEL_ROOT%"
set "PYTHONIOENCODING=utf-8"

pushd "%GUIDE_ROOT%"
"%ENV_PATH%\python.exe" script\download_model.py ^
  --repo-id %RAW_MODEL_ID% ^
  --output "%RAW_MODEL_PATH%"
if errorlevel 1 goto :pop_error
popd

echo [OK] Raw model download finished.
exit /b 0

:pop_error
popd
echo [ERROR] Raw model download failed.
echo         Accept the Gemma license and login first:
echo         "%ENV_PATH%\Scripts\hf.exe" auth login
exit /b 1
