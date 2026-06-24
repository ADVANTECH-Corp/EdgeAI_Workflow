# How to convert VLM with Intel OpenVINO and inference with OVMS: gemma-3-4b (CPU / iGPU / NPU)

This example demonstrates how to prepare Gemma 3 4B VLM models and serve them with OpenVINO Model Server on an Intel platform.

- [Environment](#environment)
  - [Target](#target)
  - [Development](#development) 
- [Develop Flow](#develop-flow)
  - [Download / Prepare OpenVINO IR Model](#download--prepare-openvino-ir-model)
- [Deploy](#deploy)
  - [Prepare OVMS](#prepare-ovms)
  - [Run OVMS](#run-ovms)
  - [Run Chat Client](#run-chat-client)

</br>

# Environment

Refer to the following requirements to prepare the target and development environment.

Base on **Edge AI SDK 3.6.4**

## Target

| Item | Content | Note |
| --- | --- | --- |
| Platform | Advantech EdgeAI Intel platform | CPU / iGPU / NPU |
| OS | Windows 11 | Command Prompt or PowerShell |
| Python | 3.11 | Created by product Miniconda |
| OpenVINO | 2026.1.0 | Runtime and GenAI packages |
| OVMS | 2026.2.0 | Official OpenVINO Model Server |
| RAM | 16 GB or higher | 32 GB recommended |
| Disk | 30 GB free or higher | For model and OVMS package |

Base on Edge AI SDK 3.6.4 product Miniconda:

```bat
C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3
```

## Development

Build a dedicated Python environment for model download and validation.

Check disk space first:

```powershell
Get-PSDrive C | Select-Object Name,Free,Used
```

This guide assumes the document folder and helper script folder are available on the target machine. If you clone this repository, set `GUIDE_ROOT` to the ARK-2252 guide folder:

```bat
set "GUIDE_ROOT=<repo>\EdgeAI_Workflow\ai_system\intel\ark-2252"
```

If you copy only this guide and its helper script folder to another location, set `GUIDE_ROOT` to that folder instead, for example:

```bat
set "GUIDE_ROOT=C:\Advantech\GenAI\genai_ovms_vlm_guides"
```

```bat
set "CONDA_ROOT=C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3"
set "WORKSPACE=C:\Advantech\GenAI"
set "ENV_PATH=%WORKSPACE%\envs\ovms-vlm"
set "GUIDE_ROOT=%WORKSPACE%\genai_ovms_vlm_guides"

"%CONDA_ROOT%\Scripts\conda.exe" create -p "%ENV_PATH%" python=3.11 -y
"%ENV_PATH%\python.exe" -m pip install --upgrade pip
"%ENV_PATH%\python.exe" -m pip install openvino==2026.1.0 openvino-genai==2026.1.0.0 huggingface_hub requests
```

Check:

```bat
"%ENV_PATH%\python.exe" -c "import openvino, openvino_genai; print(openvino.__version__); print('openvino_genai OK')"
```

# Develop Flow

Follow these steps to get the VLM models.

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

## Download / Prepare OpenVINO IR Model

The models above are already converted to OpenVINO IR format. The preparation step is to download the full model folder and verify the required OpenVINO files.

### Mode 1: Step-by-step Commands

The OpenVINO Gemma model repositories may require Hugging Face authentication and accepted model access terms. If access is not granted, the download can fail with `401 Unauthorized` or `GatedRepoError`.

Before running the download commands:

1. Sign in to Hugging Face.
2. Open the model repository page in a browser and accept any required access terms.
3. Log in from the command line:

```bat
"%ENV_PATH%\Scripts\huggingface-cli.exe" login
```

You can also provide a token through the environment:

```bat
set "HF_TOKEN=hf_your_token_here"
```

Create model root:

```bat
set "MODEL_ROOT=C:\Advantech\GenAI\models"
mkdir "%MODEL_ROOT%"
```

Download CPU / iGPU model:

```bat
"%ENV_PATH%\python.exe" -c "import os; from huggingface_hub import snapshot_download; p=snapshot_download(repo_id='OpenVINO/gemma-3-4b-it-int4-ov', local_dir=r'%MODEL_ROOT%\gemma-3-4b-it-int4', token=os.environ.get('HF_TOKEN')); print(p)"
```

Download NPU model:

```bat
"%ENV_PATH%\python.exe" -c "import os; from huggingface_hub import snapshot_download; p=snapshot_download(repo_id='OpenVINO/gemma-3-4b-it-int4-cw-ov', local_dir=r'%MODEL_ROOT%\gemma-3-4b-it-int4-cw-ov', token=os.environ.get('HF_TOKEN')); print(p)"
```

Check required files:

```bat
dir "%MODEL_ROOT%\gemma-3-4b-it-int4\openvino_language_model.xml"
dir "%MODEL_ROOT%\gemma-3-4b-it-int4-cw-ov\openvino_language_model.xml"
```

### Mode 2: Quick Download from Advantech-EIOT

Use the helper script:

```bat
cd /d "%GUIDE_ROOT%"
```

Download CPU / iGPU model:

```bat
"%ENV_PATH%\python.exe" script\download_model.py ^
  --repo-id Advantech-EIOT/intel_google-gemma-3-4b-it-int4 ^
  --output "%MODEL_ROOT%\gemma-3-4b-it-int4"
```

Download NPU model:

```bat
"%ENV_PATH%\python.exe" script\download_model.py ^
  --repo-id Advantech-EIOT/intel_google-gemma-3-4b-it-int4-cw-ov ^
  --output "%MODEL_ROOT%\gemma-3-4b-it-int4-cw-ov"
```


# Deploy

Launch the VLM model with official OpenVINO Model Server.

## Prepare OVMS

Download OVMS 2026.2.0 from official OpenVINO Model Server releases:

```text
https://github.com/openvinotoolkit/model_server/releases
```

For version-specific binary packages, use:

```text
https://storage.openvinotoolkit.org/repositories/openvino_model_server/packages/2026.2.0/
```

Download the Windows package, extract it to `C:\Advantech\GenAI\ovms`, then set:

```bat
set "OVMS_EXE=C:\Advantech\GenAI\ovms\ovms.exe"
```

Choose the Windows x64 package that contains `ovms.exe`. After extraction, confirm the actual location of `ovms.exe` and update `OVMS_EXE` if the extracted folder name is different.

If the Edge AI SDK product already includes OVMS, you can use the product executable instead:

```bat
set "OVMS_EXE=C:\Program Files\Advantech\EdgeAI\System\Intel\GenAI\app\engine\intel\scripts\ovms_2026_2\ovms.exe"
```

Check:

```bat
"%OVMS_EXE%" --version
```

## Run OVMS

Open a new Command Prompt for each run. If this is a new terminal, set the common variables again before running OVMS:

```bat
set "MODEL_ROOT=C:\Advantech\GenAI\models"
set "OVMS_EXE=C:\Advantech\GenAI\ovms\ovms.exe"
```

### Run CPU

```bat
"%OVMS_EXE%" ^
  --rest_port 23953 ^
  --model_path "%MODEL_ROOT%\gemma-3-4b-it-int4" ^
  --model_name gemma-3-4b-it-int4 ^
  --task text_generation ^
  --target_device CPU ^
  --pipeline_type VLM ^
  --max_num_seqs 1 ^
  --max_num_batched_tokens 1024
```

### Run iGPU

```bat
"%OVMS_EXE%" ^
  --rest_port 23953 ^
  --model_path "%MODEL_ROOT%\gemma-3-4b-it-int4" ^
  --model_name gemma-3-4b-it-int4 ^
  --task text_generation ^
  --target_device GPU ^
  --pipeline_type VLM ^
  --max_num_seqs 1 ^
  --max_num_batched_tokens 1024
```

### Run NPU

```bat
"%OVMS_EXE%" ^
  --rest_port 23953 ^
  --model_path "%MODEL_ROOT%\gemma-3-4b-it-int4-cw-ov" ^
  --model_name gemma-3-4b-it-int4-cw-ov ^
  --task text_generation ^
  --target_device NPU ^
  --pipeline_type VLM ^
  --max_num_seqs 1 ^
  --max_num_batched_tokens 1024 ^
  --max_prompt_len 2048 ^
  --cache_size 0 ^
  --enable_prefix_caching false
```

## Run Chat Client

Open another Command Prompt:

```bat
set "ENV_PATH=C:\Advantech\GenAI\envs\ovms-vlm"
cd /d "%GUIDE_ROOT%"
```

For CPU / iGPU:

```bat
"%ENV_PATH%\python.exe" script\ovms_chat_client.py ^
  --url http://127.0.0.1:23953/v3/chat/completions ^
  --model gemma-3-4b-it-int4 ^
  --once "Answer in one sentence: what is OpenVINO?"
```

For NPU:

```bat
"%ENV_PATH%\python.exe" script\ovms_chat_client.py ^
  --url http://127.0.0.1:23953/v3/chat/completions ^
  --model gemma-3-4b-it-int4-cw-ov ^
  --once "Answer in one sentence: what is OpenVINO?"
```

# Result

OVMS EX:
![result](assets/ovms.png)

Chat Client EX:
![result](assets/chatbot.png)



| Device | Model | Expected Status |
| --- | --- | --- |
| CPU | `gemma-3-4b-it-int4` | Supported |
| iGPU | `gemma-3-4b-it-int4` | Supported |
| NPU | `gemma-3-4b-it-int4-cw-ov` | Supported |



# Reference

* OpenVINO Model Server releases: https://github.com/openvinotoolkit/model_server/releases
* OpenVINO GenAI: https://docs.openvino.ai/
* Hugging Face OpenVINO models: https://huggingface.co/OpenVINO
