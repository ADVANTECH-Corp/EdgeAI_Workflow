@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  OpenVINO Object Detection - Environment Check
echo ============================================================
echo.
echo  Model name : %MODEL_NAME%
echo  Arch type  : %ARCH_TYPE%
echo.

call :check_file "Conda" "%CONDA_EXE%"
call :check_file "Conda activate" "%CONDA_ACTIVATE%"
call :check_tool "git"
call :check_tool "cmake"
call :check_dir "Workspace" "%WORKSPACE%"
call :check_dir "Open Model Zoo" "%OMZ_DIR%"
call :check_file "Conversion Python" "%CONVERT_ENV%\python.exe"
call :check_file "Runtime Python" "%RUNTIME_ENV%\python.exe"
call :check_dir "OpenCV_DIR" "%OPENCV_DIR%"
call :check_dir "OpenCV bin" "%OPENCV_BIN%"
call :check_file "Model XML" "%MODEL_XML%"
call :check_file "Model BIN" "%MODEL_BIN%"
if defined LABELS_FILE call :check_file "Labels" "%LABELS_FILE%"
call :check_file "Built app" "%APP_EXE%"
call :check_file "Product app" "%PRODUCT_APP_EXE%"
call :check_file "Demo video" "%VIDEO%"

echo.
echo [INFO] Check finished. Missing optional items may be created by the setup scripts.
exit /b 0

:check_file
if exist "%~2" (
  echo [OK]   %~1: %~2
) else (
  echo [MISS] %~1: %~2
)
exit /b 0

:check_dir
if exist "%~2\" (
  echo [OK]   %~1: %~2
) else (
  echo [MISS] %~1: %~2
)
exit /b 0

:check_tool
where %~1 >nul 2>nul
if errorlevel 1 (
  echo [MISS] Tool: %~1
) else (
  echo [OK]   Tool: %~1
)
exit /b 0
