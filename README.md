# Edge AI Workflow
The Edge AI Workflow is designed to help developers kickstart AI application development on Advantech's edge AI platforms and accelerator cards. This introductory guide provides step-by-step instructions covering from environment and tool installation, model download, conversion, quantization, application development, deployment to the target platform, and execution. It’s a comprehensive starter guide aimed at making the development and deployment of AI applications more accessible and efficient.

![eas_ai_workflow](assets/EAS_Startkit_flow.png)

# AI System
| Vendor | Device |  SOC | OS |  README |
| -------- | -------- | -------- | ---- | ---- |
| Qualcomm | AOM-DK2721  | QCS640 | LE/QIRP 1.1 Yocto-4.0 | [How To](ai_system/qualcomm/aom-dk2721/README.md) |
| Intel | AFE-R360    | Intel Core Ultra | Ubuntu 24.04 | [How To](ai_system/intel/afe-r360/README.md)  |
| NVIDIA | AIR-030     | Jetson AGX Orin | Ubuntu-22.04-tegra | [How To](ai_system/jetson/air-030/README.md)  |
| NVIDIA | EPC-R7300   | Jetson Orin NX/Nano   | Ubuntu-22.04-tegra | [How To](ai_system/jetson/epc-r7300/README.md)  |
| AMD | AIMB-2210   | AMD Ryzen 8000 Series | Windows 11 IoT Enterprise LTSC | [How To](ai_system/amd/aimb-2210/README.md)  |


# AI Accelerator
| Vendor | Model |  SOC | OS |  README |
| -------- | -------- | -------- | ---- | ---- |
| Hailo | EAI-1200 <br/> EAI-3300    | Hailo-8 | Ubuntu 22.04 | [How To](ai_accelerator/hailo/eai-1200_3300/README.md) |
