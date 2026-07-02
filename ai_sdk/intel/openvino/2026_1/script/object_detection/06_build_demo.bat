@echo off
setlocal EnableExtensions

call "%~dp0\00_config.bat"
if errorlevel 1 exit /b 1

echo.
echo ============================================================
echo  Step 06 - Build Open Model Zoo object_detection_demo
echo ============================================================
echo  OMZ demos      : %OMZ_DIR%\demos
echo  Build dir      : %BUILD_DIR%
echo  OpenCV_DIR     : %OPENCV_DIR%
echo  OpenVINO_DIR   : %OPENVINO_CMAKE_DIR%
echo.

where cmake >nul 2>nul
if errorlevel 1 (
  echo [ERROR] cmake was not found in PATH.
  exit /b 1
)

if not exist "%OMZ_DIR%\demos\CMakeLists.txt" (
  echo [ERROR] Open Model Zoo demos were not found.
  echo         Run 04_download_model.bat first.
  exit /b 1
)

if not exist "%OPENCV_DIR%" (
  echo [ERROR] OpenCV_DIR does not exist: %OPENCV_DIR%
  echo         Install OpenCV or update OPENCV_DIR in 00_config.bat.
  exit /b 1
)

if not exist "%OPENVINO_CMAKE_DIR%\OpenVINOConfig.cmake" (
  echo [ERROR] OpenVINOConfig.cmake was not found:
  echo         %OPENVINO_CMAKE_DIR%
  echo         Run 03_prepare_runtime_env.bat first.
  exit /b 1
)

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if errorlevel 1 exit /b 1

pushd "%BUILD_DIR%"
echo [INFO] Configuring CMake...
cmake ^
  -DOpenCV_DIR="%OPENCV_DIR%" ^
  -DOpenVINO_DIR="%OPENVINO_CMAKE_DIR%" ^
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
  "%OMZ_DIR%\demos"
if errorlevel 1 goto :pop_error

echo [INFO] Building object_detection_demo...
cmake --build . --config Release --target object_detection_demo
if errorlevel 1 goto :pop_error
popd

if not exist "%APP_EXE%" (
  echo [ERROR] Built executable was not found:
  echo         %APP_EXE%
  exit /b 1
)

if exist "%OPENCV_BIN%\opencv_world*.dll" (
  echo [INFO] Copying OpenCV runtime DLLs...
  copy "%OPENCV_BIN%\opencv_world*.dll" "%APP_DIR%\" >nul
) else (
  echo [WARN] OpenCV runtime DLLs were not found: %OPENCV_BIN%\opencv_world*.dll
  echo        Copy them manually if the demo cannot start.
)

echo [OK] Object detection demo build finished.
exit /b 0

:pop_error
popd
echo [ERROR] Build failed.
exit /b 1
