#!/usr/bin/env bash

WORKSPACE=${WORKSPACE:-$HOME/edgeai-workflow/vision}
SDK_ROOT=${SDK_ROOT:-/opt/Advantech/EdgeAI/System/Intel/SDK}
OV_RUNTIME=${OV_RUNTIME:-$SDK_ROOT/runtime/openvino_2026_3/lib}
PYTHON_BIN=${PYTHON_BIN:-python3}
OMZ_DIR=$WORKSPACE/open_model_zoo
OMZ_REF=7cc29a91472b4cb1289a11e655ba3e188e1d4a31
CONVERT_ENV=$WORKSPACE/envs/omz-py310
BUILD_ENV=$WORKSPACE/envs/openvino-build
BUILD_DIR=$WORKSPACE/build
MODEL_DIR=$WORKSPACE/models
PREPARED_YOLO_DIR=$MODEL_DIR/advantech/yolo-v4-tf/FP16
APP_EXE=$BUILD_DIR/intel64/Release/object_detection_demo
DEMO_INPUT=${DEMO_INPUT:-/opt/Advantech/EdgeAI/Main/Data/video/ObjectDetection.mp4}
