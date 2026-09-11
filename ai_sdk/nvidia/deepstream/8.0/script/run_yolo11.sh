#!/bin/bash
set -e

APPDIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE="${IMAGE:-nvcr.io/nvidia/deepstream:8.0-samples-multiarch}"
CONFIG="deepstream_app_config_yoloV11_video.txt"

if [[ "${1:-}" == *"camera"* ]]; then
  CONFIG="deepstream_app_config_yoloV11_usb-camera.txt"
fi

for path in \
  "$CONFIG" \
  "config_infer_primary_yolo11.txt" \
  "labels.txt" \
  "yolo11m.onnx" \
  "nvdsinfer_custom_impl_Yolo/libnvdsinfer_custom_impl_Yolo.so"; do
  if [ ! -e "$APPDIR/$path" ]; then
    echo "Missing required file: $APPDIR/$path"
    exit 1
  fi
done

if [ ! -e "$APPDIR/model_b1_gpu0_fp32.engine" ]; then
  echo "model_b1_gpu0_fp32.engine not found; DeepStream will try to build it from yolo11m.onnx."
fi

echo "Using config: $CONFIG"
echo "Using image : $IMAGE"

xhost +local:docker >/dev/null 2>&1 || xhost + >/dev/null 2>&1 || true

docker run -it --rm \
  --entrypoint /bin/bash \
  --runtime=nvidia \
  --network=host \
  -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,video,graphics \
  --gpus all \
  --privileged \
  -v "$APPDIR:/EdgeAI" \
  -e DISPLAY="${DISPLAY:-:0}" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /etc/X11:/etc/X11:ro \
  "$IMAGE" \
  -lc "cd /EdgeAI && echo 'Starting deepstream-app...' && deepstream-app -c $CONFIG"
