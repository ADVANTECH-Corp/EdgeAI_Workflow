#!/bin/bash

set -euo pipefail

# Define the error handling function
error_handler() {
    local line_no=$1
    local failed_command=$2
    echo ""
    echo "❌ [Error] Script execution failed!"
    echo "👉 Error occurred on line: $line_no"
    echo "👉 Failed command: $failed_command"
    echo "Please check the output logs above for more details."
    echo "==================================="
    exit 1
}

# Trap the ERR signal (triggers error_handler when any command fails)
trap 'error_handler ${LINENO} "$BASH_COMMAND"' ERR

# ==========================================
#  Environment Variables Configuration
# ==========================================
WORK_DIR="$HOME/aisdk"
OPENCV_INSTALL_DIR="$WORK_DIR/opencv"
GFLAGS_INSTALL_DIR="$WORK_DIR/gflags"

# ==========================================
#  Main Script Execution
# ==========================================
echo "Checking for existing working directory..."
if [ -d "$WORK_DIR" ]; then
    echo "Directory exists. Deleting it..."
    rm -rf "$WORK_DIR"
fi

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# ------------------------------------------
#  Build OpenCV
# ------------------------------------------
echo "Cloning OpenCV 4.11.0..."
git clone https://github.com/opencv/opencv.git -b 4.11.0
cd opencv

mkdir mybuild && cd mybuild

echo "Configuring OpenCV..."
cmake -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX="$OPENCV_INSTALL_DIR" \
      -D BUILD_SHARED_LIBS=ON \
      -D BUILD_LIST=core,imgproc,highgui,imgcodecs,videoio,calib3d,features2d,photo,flann,ml,stitching,video,dnn \
      -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF \
      -D WITH_FFMPEG=ON \
      -D OPENCV_GENERATE_PKGCONFIG=ON ..

echo "Building OpenCV..."
make -j$(nproc)

echo "Installing OpenCV..."
make install

# ------------------------------------------
#  Build gflags
# ------------------------------------------
cd "$WORK_DIR"
echo "Cloning gflags..."
git clone https://github.com/gflags/gflags.git
cd gflags

mkdir mybuild && cd mybuild

echo "Configuring gflags..."
cmake -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX="$GFLAGS_INSTALL_DIR" \
      -D BUILD_SHARED_LIBS=ON ..

echo "Building gflags..."
make -j$(nproc)

echo "Installing gflags..."
make install

echo "==================================="
echo " ✅ All builds completed successfully!"
echo "==================================="