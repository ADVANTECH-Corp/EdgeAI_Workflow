@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

set "PROMPT=%~1"
if "%PROMPT%"=="" set "PROMPT=%CHAT_PROMPT%"

echo.
echo ============================================================
echo  Gemma 4 12B - Chat client
echo ============================================================
echo  URL   : %CHAT_URL%
echo  Model : %OV_MODEL_NAME%
echo.

if not exist "%ENV_PATH%\python.exe" (
  echo [ERROR] Python environment was not found. Run 02_prepare_convert_env.bat first.
  exit /b 1
)

pushd "%GUIDE_ROOT%"
"%ENV_PATH%\python.exe" script\ovms_chat_client.py ^
  --url %CHAT_URL% ^
  --model %OV_MODEL_NAME% ^
  --once "%PROMPT%"
set "RESULT=%errorlevel%"
popd
exit /b %RESULT%
