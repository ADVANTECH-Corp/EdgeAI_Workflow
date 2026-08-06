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
call :check_file "Git" "%GIT_EXE%" "Install Git for Windows, or set GIT_EXE before running scripts. Download: https://git-scm.com/download/win"
call :check_file "CMake" "%CMAKE_EXE%" "Install CMake or Visual Studio Build Tools, or set CMAKE_EXE before running build scripts. Download: https://cmake.org/download/"
call :check_file "Visual Studio Developer Command" "%VSDEVCMD%" "Install Microsoft Visual Studio Build Tools 2022 with Desktop development with C++ workload: https://visualstudio.microsoft.com/zh-hant/visual-cpp-build-tools/"
call :check_msvc_tool "MSVC compiler" "cl"
call :check_msvc_tool "NMake" "nmake"
call :check_dir "Workspace" "%WORKSPACE%"
call :check_dir "Open Model Zoo" "%OMZ_DIR%"
call :check_file "Conversion Python" "%CONVERT_ENV%\python.exe"
call :check_file "Runtime Python" "%RUNTIME_ENV%\python.exe"
call :check_dir "OpenCV_DIR" "%OPENCV_DIR%" "Download OpenCV 4.13.0, or set OPENCV_DIR/OPENCV_PATH before running build scripts. Download: https://github.com/opencv/opencv/releases/download/4.13.0/opencv-4.13.0-windows.exe"
call :check_dir "OpenCV bin" "%OPENCV_BIN%" "Check the OpenCV extraction path. If it is different, set OPENCV_DIR before running build scripts."
call :check_file "Model XML" "%MODEL_XML%"
call :check_file "Model BIN" "%MODEL_BIN%"
if defined LABELS_FILE call :check_file "Labels" "%LABELS_FILE%"
call :check_file "Built app" "%APP_EXE%"
call :check_file "Product app" "%PRODUCT_APP_EXE%"
call :check_file "Demo video" "%VIDEO%"

echo.
echo [INFO] Check finished.
echo [INFO] Missing workspace, model, env, or build output may be created by setup scripts.
echo [INFO] Git, CMake, and OpenCV are auto-detected from common paths when possible.
echo [INFO] If auto-detection fails, set GIT_EXE, CMAKE_EXE, or OPENCV_DIR before running scripts.
echo [INFO] Demo build also requires Microsoft C++ Build Tools. The build script uses Visual Studio generator when Build Tools are installed.
exit /b 0

:check_file
if "%~2"=="" goto :check_file_missing_empty
if exist "%~2" goto :check_file_ok
echo [MISS] %~1: %~2
if not "%~3"=="" echo        %~3
exit /b 0

:check_file_missing_empty
echo [MISS] %~1: not found
if not "%~3"=="" echo        %~3
exit /b 0

:check_file_ok
echo [OK]   %~1: %~2
exit /b 0

:check_dir
if exist "%~2\" goto :check_dir_ok
echo [MISS] %~1: %~2
if not "%~3"=="" echo        %~3
exit /b 0

:check_dir_ok
echo [OK]   %~1: %~2
exit /b 0

:check_msvc_tool
where %~2 >nul 2>nul
if errorlevel 1 (
  if defined VSDEVCMD (
    echo [INFO] %~1: %~2 is not in current PATH, but Visual Studio Build Tools were found.
  ) else (
    echo [MISS] %~1: %~2 not found
    echo        Install Visual Studio Build Tools with the C++ workload.
  )
) else (
  for /f "delims=" %%I in ('where %~2 2^>nul') do (
    echo [OK]   %~1: %%I
    exit /b 0
  )
)
exit /b 0
