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

| Environment    | Frameworks  | Description/Source  | Version |
|----------------|-------------|---------------------|---------|
| **Host**       | HailoRT     | [HailoRT (PCIe driver,Python 3.10 package)](https://hailo.ai/products/hailo-software/hailo-ai-software-suite/#sw-hailort)    | 4.20.0  |
| **Docker**     | TAPPAS<br>OpenCV<br>GStreamer<br>PyGObject    | TAPPAS: [link](https://hailo.ai/products/hailo-software/hailo-ai-software-suite/#sw-tappas)<br>OpenCV: [link](https://github.com/opencv/opencv.git)<br>GStreamer: [link](https://gstreamer.freedesktop.org/index.html)<br>PyGObject: [link](https://pygobject.gnome.org/getting_started.html#ubuntu-logo-ubuntu-debian-logo-debian) | TAPPAS: 3.31.0<br>OpenCV: 4.5.4<br>GStreamer: 1.20.3<br>PyGObject: 3.42.0 |
| **Docker Image** | -         | `advigw/eas-x86-hailo8:ubuntu22.04-1.0.0`   | 1.0.0   |


### Install HailoRT & PCIe Driver
```
$ sudo apt-get update -y
$ sudo apt install -y build-essential gcc-12
$ sudo apt install -y dkms build-essential linux-headers-$(uname -r)
```
```
$ git clone https://github.com/ADVANTECH-Corp/EdgeAI_Workflow.git
$ cd EdgeAI_Workflow/ai_accelerator/eai-1200_3300/tool

$ echo "dkms dkms/autoinstall boolean true" | sudo debconf-set-selections
$ echo "Y" | sudo DEBIAN_FRONTEND=noninteractive dpkg -i hailort-pcie-driver_4.20.0_all.deb
$ echo "Y" | sudo DEBIAN_FRONTEND=noninteractive dpkg -i hailort_4.20.0_amd64.deb
```


### Install Docker & Hailo Docker
1. Install Docker Step on [Docker Install](https://docs.docker.com/engine/install/ubuntu/)
2. docker pull
```
$ docker pull advigw/eas-x86-hailo8:ubuntu22.04-1.0.0
```

<br/>

---

<a name="Deploy"/>

# Deploy
Launch an AI application.

<a name="Application"/>

## Run Application
### Objection Detection


Single-Command Execution
```
$ xhost +local:

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
  bash -c "/local/workspace/tappas/apps/h8/gstreamer/general/detection/detection_new.sh"
```

Interactive Mode Execution
```
$ xhost +local:

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

$ cd /local/workspace/tappas/apps/h8/gstreamer/general/detection/
$ ./detection_new.sh
```

Result:

![EAS_Startkit_object-detection](assets/hailo_object_detection_video.png)

---

### Change Input Video or Model

You can directly change the input source or select a model using command-line arguments when running `detection_new.sh`.

#### Change Input Source

- **Use MP4 file as input:**

  ```bash
  $ ./detection_new.sh --input <video_path>/sample.mp4
  ```

- **Use USB Camera as input:**

  ```bash
  $ ./detection_new.sh --input /dev/video0
  ```

#### Change Model

To switch the model, use the `--network` parameter. Only the following models are supported:

- `yolov5s`
- `yolov8m`
- `mobilenet_ssd`

**Example:**

```bash
$ ./detection_new.sh -i /dev/video0 --network yolov8m
```

> See more supported parameters and usage in [this link](https://github.com/hailo-ai/tappas/tree/master/apps/h8/gstreamer/general/detection)

