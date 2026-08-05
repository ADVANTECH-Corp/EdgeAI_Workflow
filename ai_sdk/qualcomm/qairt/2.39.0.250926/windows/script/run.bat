@echo off
setlocal

:: --- 1. Set Variables ---
set "WORK_DIR=C:\temp\aisdk"

set "OPENCV_INSTALL_DIR=%WORK_DIR%\opencv"
set "GFLAGS_INSTALL_DIR=%WORK_DIR%\gflags"

:: --- 2. Clean and Create Working Directory ---
echo Checking for existing working directory at "%WORK_DIR%"...
if exist "%WORK_DIR%" (
    echo Directory exists. Deleting it completely...
    rmdir /S /Q "%WORK_DIR%"
    echo   Directory deleted
)

echo Creating new working directory...
mkdir "%WORK_DIR%"
if %errorlevel% neq 0 (
    echo   FAILED to create directory.
    goto :eof
)

echo Successfully created %WORK_DIR%.
cd /D "%WORK_DIR%"

:: --- 3. Compile OpenCV ---
echo Cloning OpenCV 4.11.0...
git clone https://github.com/opencv/opencv.git -b 4.11.0
if %errorlevel% neq 0 ( echo FAILED: git clone opencv & goto :eof )

cd opencv
rd /s /q mybuild
mkdir mybuild
cd mybuild

echo Configuring OpenCV with CMake...
cmake -G "Visual Studio 17 2022" ^
  -A ARM64 -T host=x64 ^
  -DCMAKE_CONFIGURATION_TYPES=Release ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%OPENCV_INSTALL_DIR%" ^
  -DBUILD_SHARED_LIBS=ON ^
  -DBUILD_LIST=core,imgproc,highgui,imgcodecs,videoio,calib3d,features2d,photo,flann,ml,stitching,video,dnn ^
  -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_opencv_apps=OFF -DBUILD_opencv_gapi=OFF ^
  -DWITH_FFMPEG=OFF -DWITH_IPP=OFF ^
  -DOPENCV_ENABLE_INTRINSICS=OFF ^
  -DCPU_BASELINE= ^
  -DCPU_DISPATCH= ^
  -DCMAKE_C_FLAGS="/D _M_ARM64=1" ^
  -DCMAKE_CXX_FLAGS="/D _M_ARM64=1" ^
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ^
  -B build -S ..

if %errorlevel% neq 0 ( echo FAILED: cmake configure opencv & goto :eof )

echo Building OpenCV...
cmake --build build --config Release -- /m
if %errorlevel% neq 0 ( echo FAILED: cmake build opencv & goto :eof )

echo Installing OpenCV...
cmake --install build --config Release
if %errorlevel% neq 0 ( echo FAILED: cmake install opencv & goto :eof )

:: --- 4. Return to Working Directory ---
cd /D "%WORK_DIR%"

:: --- 5. Compile gflags ---
echo Cloning gflags...
git clone https://github.com/gflags/gflags.git
if %errorlevel% neq 0 ( echo FAILED: git clone gflags & goto :eof )

cd gflags
rd /s /q mybuild
mkdir mybuild
cd mybuild

echo Configuring gflags with CMake...
cmake -G "Visual Studio 17 2022" ^
  -A ARM64 -T host=x64 ^
  -DCMAKE_CONFIGURATION_TYPES=Release ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%GFLAGS_INSTALL_DIR%" ^
  -DBUILD_SHARED_LIBS=ON ^
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ^
  -B build -S ..
if %errorlevel% neq 0 ( echo FAILED: cmake configure gflags & goto :eof )

echo Building gflags...
cmake --build build --config Release -- /m
if %errorlevel% neq 0 ( echo FAILED: cmake build gflags & goto :eof )

echo Installing gflags...
cmake --install build --config Release
if %errorlevel% neq 0 ( echo FAILED: cmake install gflags & goto :eof )

:: --- 6. Finish ---
cd /D "%WORK_DIR%"
echo.
echo ===================================
echo  All builds completed successfully!
echo ===================================
echo.

endlocal