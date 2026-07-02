# How to convert VLM with Intel OpenVINO and inference with OVMS: gemma-3-4b

This example demonstrates how to prepare Gemma 3 4B VLM models and serve them with OpenVINO Model Server on an Intel platform.

Gemma 3 4B uses prepared OpenVINO IR models. The setup and deploy commands are packaged as batch scripts under `script\genai\gemma3_4b`.

- [Environment](#environment)
  - [Target](#target)
  - [Model Selection](#model-selection)
- [Script Workflow](#script-workflow)
  - [Configuration](#configuration)
  - [Download Models](#download-models)
- [Deploy](#deploy)
- [Result](#result)
- [Reference](#reference)

</br>

# Environment

Refer to the following requirements to prepare the target and development environment.

Base on **Edge AI SDK**

## Target

| Item | Content | Note |
| --- | --- | --- |
| Platform | Advantech EdgeAI Intel platform | CPU / iGPU / NPU |
| OS | Windows 11 | Command Prompt |
| Python | 3.11 | Created by product Miniconda |
| OpenVINO | 2026.1.0 | Runtime and GenAI packages |
| OVMS | 2026.2.0 | Official OpenVINO Model Server |
| RAM | 16 GB or higher | 32 GB recommended |
| Disk | 30 GB free or higher | For models and OVMS package |

Base on Edge AI SDK product Miniconda:

```text
C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3
```

## Model Selection

| Device | Model Folder | Hugging Face Repo | Note |
| --- | --- | --- | --- |
| CPU | `gemma-3-4b-it-int4` | `Advantech-EIOT/intel_google-gemma-3-4b-it-int4` | Standard INT4 OpenVINO model |
| iGPU | `gemma-3-4b-it-int4` | `Advantech-EIOT/intel_google-gemma-3-4b-it-int4` | Use OVMS `--target_device GPU` |
| NPU | `gemma-3-4b-it-int4-cw-ov` | `Advantech-EIOT/intel_google-gemma-3-4b-it-int4-cw-ov` | Channel-wise INT4 model for NPU |

The OpenVINO organization equivalents are:

```text
OpenVINO/gemma-3-4b-it-int4-ov
OpenVINO/gemma-3-4b-it-int4-cw-ov
```

# Script Workflow

The Gemma 3 4B scripts are located in:

```text
ai_system\intel\openvino\script\genai\gemma3_4b
```

| Script | Purpose |
| --- | --- |
| `00_config.bat` | Common paths, model names, repository ids, OVMS path, and port |
| `check_env.bat` | Prints the current environment and highlights missing files |
| `01_prepare_workspace.bat` | Creates `C:\Advantech\GenAI` workspace folders |
| `02_prepare_env.bat` | Creates Python 3.11 environment and installs OpenVINO GenAI packages |
| `03_download_cpu_igpu_model.bat` | Downloads the CPU / iGPU prepared OpenVINO IR model |
| `04_download_npu_model.bat` | Downloads the NPU channel-wise INT4 OpenVINO IR model |
| `05_check_models.bat` | Checks required model files |
| `10_check_ovms.bat` | Checks `ovms.exe` |
| `11_run_ovms_cpu.bat` | Starts OVMS on CPU |
| `12_run_ovms_igpu.bat` | Starts OVMS on iGPU |
| `13_run_ovms_npu.bat` | Starts OVMS on NPU |
| `20_chat_cpu_igpu.bat` | Sends a test prompt to the CPU / iGPU model |
| `21_chat_npu.bat` | Sends a test prompt to the NPU model |
| `run_all_download.bat` | Runs workspace, environment, model download, and model check steps |

## Configuration

Before running setup, review:

```bat
script\genai\gemma3_4b\00_config.bat
```

Default paths:

| Variable | Default |
| --- | --- |
| `CONDA_ROOT` | `C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3` |
| `WORKSPACE` | `C:\Advantech\GenAI` |
| `ENV_PATH` | `%WORKSPACE%\envs\ovms-vlm` |
| `MODEL_ROOT` | `%WORKSPACE%\models` |
| `OVMS_EXE` | `%WORKSPACE%\ovms\ovms.exe` |
| `REST_PORT` | `23953` |

If the Edge AI SDK product already includes OVMS, the scripts also check:

```text
C:\Program Files\Advantech\EdgeAI\System\Intel\GenAI\app\engine\intel\scripts\ovms_2026_2\ovms.exe
```

## Download Models

Some Hugging Face repositories may require authentication and accepted access terms. If access is not granted, downloads can fail with `401 Unauthorized` or `GatedRepoError`.

Before downloading gated models:

```bat
cd /d <repo>\ai_system\intel\openvino
"C:\Advantech\GenAI\envs\ovms-vlm\Scripts\huggingface-cli.exe" login
```

You can also set a token in the same Command Prompt:

```bat
set "HF_TOKEN=hf_your_token_here"
```

Run the full download setup:

```bat
cd /d <repo>\ai_system\intel\openvino
script\genai\gemma3_4b\run_all_download.bat
```

Or run each step:

```bat
script\genai\gemma3_4b\check_env.bat
script\genai\gemma3_4b\01_prepare_workspace.bat
script\genai\gemma3_4b\02_prepare_env.bat
script\genai\gemma3_4b\03_download_cpu_igpu_model.bat
script\genai\gemma3_4b\04_download_npu_model.bat
script\genai\gemma3_4b\05_check_models.bat
```

Expected model files:

```text
C:\Advantech\GenAI\models\gemma-3-4b-it-int4\openvino_language_model.xml
C:\Advantech\GenAI\models\gemma-3-4b-it-int4-cw-ov\openvino_language_model.xml
```

# Deploy

Download OVMS 2026.2.0 from official OpenVINO Model Server releases:

```text
https://github.com/openvinotoolkit/model_server/releases
https://storage.openvinotoolkit.org/repositories/openvino_model_server/packages/2026.2.0/
```

Download the Windows package, extract it to `C:\Advantech\GenAI\ovms`, then verify:

```bat
script\genai\gemma3_4b\10_check_ovms.bat
```

Open one Command Prompt for OVMS and run one target device:

```bat
script\genai\gemma3_4b\11_run_ovms_cpu.bat
script\genai\gemma3_4b\12_run_ovms_igpu.bat
script\genai\gemma3_4b\13_run_ovms_npu.bat
```

The NPU script uses the channel-wise INT4 model and adds NPU-specific OVMS options:

```text
--max_prompt_len 2048
--cache_size 0
--enable_prefix_caching false
```

Open another Command Prompt and run the chat client:

```bat
script\genai\gemma3_4b\20_chat_cpu_igpu.bat
script\genai\gemma3_4b\21_chat_npu.bat
```

# Result

OVMS EX:
![result](assets/ovms.png)

Chat Client EX:
![result](assets/chatbot.png)

| Device | Model | OVMS Script | Chat Script | Expected Status |
| --- | --- | --- | --- | --- |
| CPU | `gemma-3-4b-it-int4` | `11_run_ovms_cpu.bat` | `20_chat_cpu_igpu.bat` | Supported |
| iGPU | `gemma-3-4b-it-int4` | `12_run_ovms_igpu.bat` | `20_chat_cpu_igpu.bat` | Supported |
| NPU | `gemma-3-4b-it-int4-cw-ov` | `13_run_ovms_npu.bat` | `21_chat_npu.bat` | Supported |

# Reference

* OpenVINO Model Server releases: https://github.com/openvinotoolkit/model_server/releases
* OpenVINO GenAI: https://docs.openvino.ai/
* Hugging Face OpenVINO models: https://huggingface.co/OpenVINO
