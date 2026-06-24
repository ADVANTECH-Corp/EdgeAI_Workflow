# How to convert VLM with Intel OpenVINO and inference with OVMS: gemma-4-12b (CPU / iGPU)

This example demonstrates how to prepare Gemma 4 12B VLM with OpenVINO and serve it with OpenVINO Model Server on CPU or iGPU.

NPU is not included in this flow. Gemma 4 12B VLM is not validated for NPU in this guide.

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
| Platform | Advantech EdgeAI Intel platform | CPU / iGPU |
| OS | Windows 11 | Command Prompt or PowerShell |
| Python | 3.11 | Created by product Miniconda |
| OpenVINO | 2026.1.0 | Runtime and GenAI packages |
| OVMS | 2026.2.0 | Official OpenVINO Model Server |
| RAM for conversion | 64 GB or higher | 16 GB edge systems are not recommended for conversion |
| Disk for conversion | 100 GB free or higher | Raw model + converted model + cache |

Base on Edge AI SDK 3.6.4 product Miniconda:

```bat
C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3
```

## Development

Build a dedicated Python environment.

Check disk space first. Do not start Gemma 4 12B download or conversion unless the conversion machine has enough free space.

```powershell
Get-PSDrive C | Select-Object Name,Free,Used
```

This guide assumes the document folder and helper scripts are extracted to `C:\Advantech\GenAI\genai_ovms_vlm_guides`. If you use another location, change `GUIDE_ROOT` in the commands below.

```bat
set "CONDA_ROOT=C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3"
set "WORKSPACE=C:\Advantech\GenAI"
set "ENV_PATH=%WORKSPACE%\envs\gemma4_12b_convert"
set "GUIDE_ROOT=%WORKSPACE%\genai_ovms_vlm_guides"

"%CONDA_ROOT%\Scripts\conda.exe" create -p "%ENV_PATH%" python=3.11 -y
"%ENV_PATH%\python.exe" -m pip install --upgrade pip
"%ENV_PATH%\python.exe" -m pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision
"%ENV_PATH%\python.exe" -m pip install transformers==5.12.1 optimum==2.2.0 openvino==2026.1.0 openvino-genai==2026.1.0.0 nncf accelerate huggingface_hub safetensors pillow sentencepiece protobuf requests
"%ENV_PATH%\python.exe" -m pip install --upgrade --no-deps git+https://github.com/huggingface/optimum-intel.git
```

Check:

```bat
"%ENV_PATH%\python.exe" -c "import transformers, openvino, openvino_genai; import importlib.metadata as m; print(transformers.__version__); print(openvino.__version__); print(m.version('optimum-intel'))"
```

# Develop Flow

Follow these steps to download and convert Gemma 4 12B.

## Download Model

Login to Hugging Face if the model requires access:

```bat
"%ENV_PATH%\Scripts\hf.exe" auth login
```

Set paths:

```bat
set "MODEL_ID=google/gemma-4-12B-it"
set "WORKSPACE=C:\Advantech\GenAI\models\gemma4_12b_from_scratch"
set "RAW_MODEL=%WORKSPACE%\raw_model"
set "OV_MODEL=%WORKSPACE%\openvino_int4"
mkdir "%WORKSPACE%"
```

Download raw model:

```bat
"%ENV_PATH%\python.exe" -c "from huggingface_hub import snapshot_download; p=snapshot_download(repo_id=r'%MODEL_ID%', local_dir=r'%RAW_MODEL%'); print(p)"
```

Check:

```bat
dir "%RAW_MODEL%\config.json"
dir "%RAW_MODEL%\*.safetensors"
dir "%RAW_MODEL%\tokenizer.json"
```

## Convert & Optimize

Use the provided conversion script:

```bat
set "GUIDE_ROOT=C:\Advantech\GenAI\genai_ovms_vlm_guides"
cd /d "%GUIDE_ROOT%"
```

Run conversion:

```bat
"%ENV_PATH%\python.exe" scripts\convert_gemma4_12b_openvino.py ^
  --model "%RAW_MODEL%" ^
  --output "%OV_MODEL%" ^
  --precision int4
```

The expected output folder should contain:

```text
config.json
generation_config.json
openvino_language_model.xml
openvino_language_model.bin
openvino_text_embeddings_model.xml
openvino_vision_embeddings_model.xml
openvino_tokenizer.xml
openvino_detokenizer.xml
tokenizer.json
processor_config.json
```

Important:

```text
Gemma 4 12B conversion is not recommended on a 16 GB RAM edge device.
Use a higher-memory development/conversion machine, then copy the converted OpenVINO folder to the edge device.
NPU is not covered by this guide.
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

Check:

```bat
"%OVMS_EXE%" --version
```

## Run OVMS

Open a new Command Prompt for each run. If this is a new terminal, set the common variables again before running OVMS:

```bat
set "OV_MODEL=C:\Advantech\GenAI\models\gemma4_12b_from_scratch\openvino_int4"
set "OVMS_EXE=C:\Advantech\GenAI\ovms\ovms.exe"
```

### Run CPU

```bat
"%OVMS_EXE%" ^
  --rest_port 23953 ^
  --model_path "%OV_MODEL%" ^
  --model_name gemma-4-12b-it-int4 ^
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
  --model_path "%OV_MODEL%" ^
  --model_name gemma-4-12b-it-int4 ^
  --task text_generation ^
  --target_device GPU ^
  --pipeline_type VLM ^
  --max_num_seqs 1 ^
  --max_num_batched_tokens 1024 ^
  --cache_size 1
```

## Run Chat Client

Open another Command Prompt:

```bat
set "ENV_PATH=C:\Advantech\GenAI\envs\gemma4_12b_convert"
set "GUIDE_ROOT=C:\Advantech\GenAI\genai_ovms_vlm_guides"
cd /d "%GUIDE_ROOT%"
```

```bat
"%ENV_PATH%\python.exe" scripts\ovms_chat_client.py ^
  --url http://127.0.0.1:23953/v3/chat/completions ^
  --model gemma-4-12b-it-int4 ^
  --once "Answer in one sentence: what is OpenVINO?"
```

# Result


OVMS EX:
![result](assets/ovms.png)

Chat Client EX:
![result](assets/chatbot.png)



| Device | Model | Expected Status |
| --- | --- | --- |
| CPU | `gemma-4-12b-it-int4` | Supported after successful conversion |
| iGPU | `gemma-4-12b-it-int4` | Supported after successful conversion |
| NPU | `gemma-4-12b-it-int4` | Not supported in this guide |


# Reference

* OpenVINO Model Server releases: https://github.com/openvinotoolkit/model_server/releases
* Running Gemma 4 with OpenVINO: https://medium.com/openvino-toolkit/running-gemma-4-with-openvino-building-a-multimodal-assistant-end-to-end-37a9ce74f0ca
* OpenVINO documentation: https://docs.openvino.ai/
