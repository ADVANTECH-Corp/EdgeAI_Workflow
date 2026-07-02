@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Step 04 - Download Open Model Zoo model
echo ============================================================
echo  OMZ dir    : %OMZ_DIR%
echo  Model name : %MODEL_NAME%
echo  Model root : %MODEL_ROOT%
echo  Arch type  : %ARCH_TYPE%
echo.

if not exist "%CONVERT_ENV%\Scripts\omz_downloader.exe" (
  echo [ERROR] omz_downloader.exe was not found.
  echo         Run 02_prepare_convert_env.bat first.
  exit /b 1
)

where git >nul 2>nul
if errorlevel 1 (
  echo [ERROR] git was not found in PATH.
  exit /b 1
)

if not exist "%OMZ_DIR%\.git" (
  echo [INFO] Cloning Open Model Zoo...
  git clone https://github.com/openvinotoolkit/open_model_zoo.git "%OMZ_DIR%"
  if errorlevel 1 goto :error
) else (
  echo [INFO] Open Model Zoo already exists. Skipping clone.
)

pushd "%OMZ_DIR%"
echo [INFO] Checking out releases/2026/1...
git checkout releases/2026/1
if errorlevel 1 goto :pop_error

echo [INFO] Updating submodules...
git submodule update --init --recursive
if errorlevel 1 goto :pop_error
popd

if not exist "%OMZ_DIR%\models\public" (
  echo [ERROR] Open Model Zoo public model folder was not found.
  exit /b 1
)

pushd "%OMZ_DIR%\models\public"
echo [INFO] Downloading %MODEL_NAME%...
"%CONVERT_ENV%\Scripts\omz_downloader.exe" ^
  --name %MODEL_NAME% ^
  --output_dir "%MODEL_ROOT%"
if errorlevel 1 goto :pop_error
popd

echo [OK] Model download step finished.
exit /b 0

:pop_error
popd
:error
echo [ERROR] Failed to download model assets.
exit /b 1
