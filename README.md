# Edge AI Workflow
The Edge AI Workflow is designed to help developers kickstart AI application development on Advantech's edge AI platforms and accelerator cards. This introductory guide provides step-by-step instructions covering from environment and tool installation, model download, conversion, quantization, application development, deployment to the target platform, and execution. It’s a comprehensive starter guide aimed at making the development and deployment of AI applications more accessible and efficient.

![eas_ai_workflow](assets/EAS_Startkit_flow.png)

# AI System
| Vendor | Device |  SOC | AI Workflow | AI Model | App & Deploy |
| -------- | -------- | -------- | ---- | ---- | ---- |
| Qualcomm | AOM-DK2721  | QCS640 | [How To](ai_system/qualcomm/aom-dk2721/README.md) | [Convert & Optimize](ai_system/qualcomm/aom-dk2721/object_detection_demo-using-qc_snpe.md#Open_AI_Model) | [Applicaton](ai_system/qualcomm/aom-dk2721/object_detection_demo-using-qc_snpe.md#Application) |
| Intel | AFE-R360    | Intel Core Ultra | [How To](ai_system/intel/afe-r360/README.md)  | [Convert & Optimize](ai_system/intel/afe-r360/object_detection_demo-using-intel_openvino.md#Covert_Optimize) |[Applicaton](ai_system/intel/afe-r360/object_detection_demo-using-intel_openvino.md#Deploy) |
| NVIDIA | AIR-030     | Jetson AGX Orin | [How To](ai_system/jetson/air-030/README.md)  | [Convert & Optimize](ai_system/jetson/air-030/object_detection_demo-using-ds7.0.md#convert-ai-model) |[Applicaton](ai_system/jetson/air-030/object_detection_demo-using-ds7.0.md#application) |
| NVIDIA | EPC-R7300   | Jetson Orin NX/Nano   | [How To](ai_system/jetson/epc-r7300/README.md)  | [Convert & Optimize](ai_system/jetson/epc-r7300/object_detection_demo-using-ds7.1.md#convert-ai-model) | [Applicaton](ai_system/jetson/epc-r7300/object_detection_demo-using-ds7.1.md#application) |
| AMD | AIMB-2210   | AMD Ryzen 8000 Series | [How To](ai_system/amd/aimb-2210/README.md)  | [Convert & Optimize](ai_system/amd/aimb-2210/object_detection_demo-using-amd_ryzenaisdk.md#download-ai-files) | [Applicaton](ai_system/amd/aimb-2210/object_detection_demo-using-amd_ryzenaisdk.md#application) |


# AI Accelerator
| Vendor | Model |  SOC | AI Workflow | AI Model | App & Deploy |
| -------- | -------- | -------- | ---- | ---- | ---- |
| Hailo | EAI-1200 <br/> EAI-3300   | Hailo-8 | [How To](ai_accelerator/hailo/eai-1200_3300/README.md) | [Convert & Optimize](ai_accelerator/hailo/eai-1200_3300/object_detection_demo-using-hailo.md#Model) | [Applicaton](ai_accelerator/hailo/eai-1200_3300/object_detection_demo-using-hailo.md#App) |
