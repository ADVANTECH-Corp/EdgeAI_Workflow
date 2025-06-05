#!/bin/bash


xhost +
txt="deepstream_app_config_yoloV11_video.txt"
 
container_id=$(docker run -it -d --rm --runtime=nvidia --network=host -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,video,graphics --gpus all --privileged -v $(pwd):/EdgeAI -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /etc/X11:/etc/X11 nvcr.io/nvidia/deepstream:7.0-samples-multiarch)
  
if [[ "$1" = *"camera"* ]]; then
 
   txt="deepstream_app_config_yoloV11_usb-camera.txt"
 
fi
  
docker exec ${container_id} /bin/bash -c "cd /EdgeAI && deepstream-app -c $txt"
 
docker stop ${container_id}
