#!/bin/bash

echo "Step 1: Grant Docker Display Permission"
xhost +local:

echo "Step 2: Launch Hailo-8 Docker container with interactive shell"
docker run --rm --privileged --network host --name adv_hailo --ipc=host \
  --device /dev/dri:/dev/dri \
  -v /tmp/hailo_docker.xauth:/home/hailo/.Xauthority \
  -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
  -v /dev:/dev \
  -v /lib/firmware:/lib/firmware \
  --group-add 44 \
  -e DISPLAY=$DISPLAY \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -e hailort_enable_service=yes \
  -it advigw/eas-x86-hailo8:ubuntu22.04-1.0.0 /bin/bash << 'EOF'

echo "Inside Docker container - Starting setup and inference pipeline"
#Source
input_source="/local/workspace/tappas/apps/h8/gstreamer/general/detection/resources/detection.mp4"
source_element="filesrc location=$input_source name=src_0 ! decodebin"
#Model
network_name="yolov8m"
hef_path="/local/workspace/tappas/apps/h8/gstreamer/general/detection/resources/yolov8m.hef"
postprocess_so="/local/workspace/tappas/apps/h8/gstreamer/libs/post_processes/libyolo_hailortpp_post.so"
json_config_path="null"
thresholds_str="nms-score-threshold=0.3 nms-iou-threshold=0.45 output-format-type=HAILO_FORMAT_TYPE_FLOAT32"
#Parameters
batch_size="1"
video_sink="fpsdisplaysink video-sink=xvimagesink text-overlay=true"
sync_pipeline=false
additional_parameters=""
device_id_prop=""
#Device Count
device_count=$(hailortcli scan | grep -c "Device:")
echo "Detected Hailo-8 devices: $device_count"

#Run GStreamer Pipeline
gst-launch-1.0 \
    $source_element ! \
    queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! \
    videoscale qos=false n-threads=2 ! video/x-raw, pixel-aspect-ratio=1/1 ! \
    queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! \
    videoconvert n-threads=2 qos=false ! \
    queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! \
    hailonet hef-path=$hef_path device-count=$device_count $device_id_prop batch-size=$batch_size $thresholds_str ! \
    queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! \
    hailofilter function-name=$network_name so-path=$postprocess_so config-path=$json_config_path qos=false ! \
    queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! \
    hailooverlay qos=false ! \
    queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! \
    videoconvert n-threads=2 qos=false ! \
    queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! \
    $video_sink name=hailo_display sync=$sync_pipeline $additional_parameters

EOF