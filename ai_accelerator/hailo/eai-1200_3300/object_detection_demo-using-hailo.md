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
| BSP | tappas | |

Base on **EdgeAI SDK 3.3.0**

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


<br/>

<a name="Deploy"/>

# Deploy
Launch an AI application.

<a name="Application"/>

## Run Application
### Objection Detection


Single-Command Execution
```
$ xhost +local:
```
```
$ docker exec -i adv_hailo bash -c "/local/workspace/tappas/apps/h8/gstreamer/general/detection/detection_new.sh"
```

Interactive Mode Execution
```
$ xhost +local:
```
```
$ docker exec -it adv_hailo /bin/bash
$ cd /local/workspace/tappas/apps/h8/gstreamer/general/detection
$ ./detection_new.sh
```

Result:

![EAS_Startkit_object-detection](assets/hailo_object_detection_video.png)

- See more on how to change the input video or model at [this link](https://github.com/hailo-ai/tappas/tree/master/apps/h8/gstreamer/general/detection).
