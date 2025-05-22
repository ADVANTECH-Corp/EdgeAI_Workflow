# Create an Object Detection on Hailo-8 ( EAI-1200 / EAI-3300 )
This example will demonstrate how to develop an vision AI Object Detection on Hailo-8 ( EAI-1200 / EAI-3300 ) platform.
Developers can easily complete the Visual AI development by following these steps.

* Application: Objection Detection
* Model: Yolov8
* Input: Video / USB Camera
  
# Table of Contents
- [Environment](#Environment)
  - [Target](#Target)
  - [Development](#Development) 
- [Deploy](#Deploy)
  - [Application](#Application)

---

<a name="Environment"/>

# Environment
Refer to the following requirements to prepare the target and develop environment.

<a name="Target"/>

## Target
| Item | Content | Note |
| -------- | -------- | -------- |
| Platform |   EAI-1200 / EAI-3300  |  EAI-1200 tested on **AIR-150** (1x Hailo-8)<br>EAI-3300 tested on **AIMB-278** (2x Hailo-8)  |
| SOC  |   Hailo-8 |  |
| OS/Kernel |  Ubuntu 22.04 iotg |  |


<a name="Development"/>

## Development

Base on **Target Environment**

System requirements
| Item | Content | Note |
| -------- | -------- | -------- |
| Platform | Intel 10 ~ 13th CPU   |  x86_64    |
| OS/Kernel | Ubuntu 22.04 | * Python 3.10 |


### AI Frameworks & Environment

| Environment    | Frameworks  | Description  | Version |
|----------------|-------------|---------------------|---------|
| **Host**       | HailoRT     | HailoRT is a production-grade, light, scalable runtime software, providing a robust library with intuitive APIs for optimized performance. Our AI SDK enables developers to build easy and fast pipelines for AI applications in production and is also suitable for evaluation and prototyping. It runs on Hailo AI Vision Processor or when utilizing Hailo AI Accelerator, it runs on the host processor and enables high throughput inferencing with one or more Hailo devices.    | 4.20.0  |
| **Docker**     | TAPPAS<br>OpenCV<br>GStreamer<br>PyGObject    | This Docker environment is built on Ubuntu 22.04 and includes TAPPAS, OpenCV, GStreamer, and PyGObject. It provides a ready-to-use platform for developing and deploying AI vision applications with the Hailo-8 accelerator. The image contains preconfigured tools and example pipelines for fast prototyping and evaluation. | TAPPAS: 3.31.0<br>OpenCV: 4.5.4<br>GStreamer: 1.20.3<br>PyGObject: 3.42.0 |
| **Docker Image** | -         | `advigw/eas-x86-hailo8:ubuntu22.04-1.0.0`   | 1.0.0   |


### Install HailoRT & PCIe Driver
```bash
$ sudo apt-get update -y
$ sudo apt install -y build-essential gcc-12
$ sudo apt install -y dkms build-essential linux-headers-$(uname -r)
```
```bash
$ git clone https://github.com/ADVANTECH-Corp/EdgeAI_Workflow.git
$ cd EdgeAI_Workflow/ai_accelerator/eai-1200_3300/tool

$ echo "dkms dkms/autoinstall boolean true" | sudo debconf-set-selections
$ echo "Y" | sudo DEBIAN_FRONTEND=noninteractive dpkg -i hailort-pcie-driver_4.20.0_all.deb
$ echo "Y" | sudo DEBIAN_FRONTEND=noninteractive dpkg -i hailort_4.20.0_amd64.deb
```


### Install Docker & Hailo Docker
1. Install Docker Step on [Docker Install](https://docs.docker.com/engine/install/ubuntu/)
2. docker pull
```bash
$ docker pull advigw/eas-x86-hailo8:ubuntu22.04-1.0.0
```

<br/>

---

<a name="Deploy"/>

# Deploy
Launch an AI application.

<a name="Application"/>

## Run Application
### Objection Detection (Yolov8m)
#### Step 1 & 2: On the Host
Open a terminal on your host machine and execute these two steps. Upon running step 2, you will enter the Hailo-8 Docker container with an interactive shell.
<br/>
<br/>
1. Grant Docker Display Permission
```bash
$ xhost +local:
```
2. Launch Docker Container for Hailo-8
```bash
$ docker run --rm --privileged --network host --name adv_hailo --ipc=host \
  --device /dev/dri:/dev/dri \
  -v /tmp/hailo_docker.xauth:/home/hailo/.Xauthority \
  -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
  -v /dev:/dev \
  -v /lib/firmware:/lib/firmware \
  --group-add 44 \
  -e DISPLAY=$DISPLAY \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -e hailort_enable_service=yes \
  -it advigw/eas-x86-hailo8:ubuntu22.04-1.0.0 \
  /bin/bash
```
#### Step 3 to 7: Inside the Docker Container
After completing step 2 and entering the Docker container, proceed with steps 3 through 7 inside the container to configure settings and start the inference pipeline.
<br/>
<br/>

3. Select Input Source (Camera or Video)
   
| Source | Command |
| -------- | -------- |
| USB Camera | $ input_source="/dev/video0"<br>$ source_element="v4l2src device=$input_source name=src_0 ! videoflip video-direction=horiz"   |
| Video File | $ input_source="/local/workspace/tappas/apps/h8/gstreamer/general/detection/resources/detection.mp4"<br>$ source_element="filesrc location=$input_source name=src_0 ! decodebin"   |

4. Model Configuration
```bash
$ network_name="yolov8m"
$ hef_path="/local/workspace/tappas/apps/h8/gstreamer/general/detection/resources/yolov8m.hef"

# Post-processing settings specific for yolov8
$ postprocess_so="/local/workspace/tappas/apps/h8/gstreamer/libs/post_processes/libyolo_hailortpp_post.so"
$ json_config_path="null"
$ thresholds_str="nms-score-threshold=0.3 nms-iou-threshold=0.45 output-format-type=HAILO_FORMAT_TYPE_FLOAT32"
```
5. Pipeline Parameter Configuration
```bash
$ batch_size="1"
$ video_sink="fpsdisplaysink video-sink=xvimagesink text-overlay=true"
$ sync_pipeline=false
$ additional_parameters=""
$ device_id_prop=""
```
6. Define Hailo-8 Device Count
```bash
$ hailortcli scan | grep -c "Device:"

# Set according to the number of Hailo-8 devices detected.
# For example, EAI-1200 may have 1 device, while EAI-3300 may have 2.
$ device_count=2
```
7. Run the GStreamer Inference Pipeline
```bash
$ gst-launch-1.0 \
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
```

8. Result:

![EAS_Startkit_object-detection](assets/hailo_object_detection_video.png)

---

### Download Script File To Quick Start
To quickly run steps 1 through 7, simply use the following script:
> Model : yolov8m <br/>
> Source : /local/workspace/tappas/apps/h8/gstreamer/general/detection/resources/detection.mp4 <br/>
> Device Count : Automatically detects and uses the maximum available Hailo-8 devices
```bash
$ cd EdgeAI_Workflow/ai_accelerator/eai-1200_3300/script
$ chmod +x hailo_detection_yolov8_video.sh
$ ./hailo_detection_yolov8_video.sh
```
---

> See more supported parameters and usage in [this link](https://github.com/hailo-ai/tappas/tree/master/apps/h8/gstreamer/general/detection)

