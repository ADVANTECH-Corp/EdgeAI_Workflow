# How to convert Gemma 4 VLM with Intel OpenVINO and inference with OVMS

This guide shows how to convert a Gemma 4 VLM model to OpenVINO INT4 IR and serve it with OpenVINO Model Server (OVMS) on CPU or iGPU.

The validated example in this guide uses:

```text
google/gemma-4-E2B-it
```

This guide uses the official OpenVINO Gemma4 notebook method and the smaller E2B model as the validated example. The original 12B path is not used as the main flow because the official Gemma4 notebook lists E2B, E4B, 26B-A4B, and 31B models.

Larger Gemma 4 models can be tried with the same method:

| Model ID | Note |
| --- | --- |
| `google/gemma-4-E2B-it` | Validated in this test round |
| `google/gemma-4-E4B-it` | Same method, requires more disk and RAM |
| `google/gemma-4-26B-A4B-it` | Same method, requires much more disk and RAM |
| `google/gemma-4-31B-it` | Same method, requires much more disk and RAM |

NPU is not included in this guide. Gemma 4 VLM is not validated for NPU here.

Validation status:

| Flow | Status |
| --- | --- |
| Official Gemma4 conversion environment | Validated |
| E2B raw model download | Validated |
| E2B OpenVINO INT4 conversion with `optimum-cli` | Validated |
| E2B OpenVINO GenAI CPU load and text generation | Validated |
| OVMS CPU / iGPU deployment | Documented, should be tested after conversion |
| E4B / 26B / 31B conversion | Documented, not validated in this test round |
| NPU deployment | Not supported in this guide |

- [Environment](#environment)
  - [Target](#target)
  - [Conversion Requirements](#conversion-requirements)
- [Model Preparation](#model-preparation)
  - [CPU / iGPU Model](#cpu--igpu-model)
  - [NPU Model](#npu-model)
  - [Hugging Face Access](#hugging-face-access)
- [Script Workflow](#script-workflow)
  - [Configuration](#configuration)
  - [Quick Start](#quick-start)
  - [Download and Convert](#download-and-convert)
- [Deploy](#deploy)
  - [Prepare OVMS](#prepare-ovms)
  - [Run OVMS](#run-ovms)
  - [Run Chat Client](#run-chat-client)
- [Result](#result)
- [Reference](#reference)

# Environment

Base on **Edge AI SDK** and the product Miniconda:

```text
C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3
```

## Target

| Item | Content | Note |
| --- | --- | --- |
| Platform | Advantech EdgeAI Intel platform | CPU / iGPU |
| OS | Windows 11 | Command Prompt |
| Python | 3.11 | Created by product Miniconda |
| OpenVINO | 2026.3.0.dev20260703 | Official Gemma4 notebook uses nightly/pre-release OpenVINO wheels |
| OVMS | 2026.2.0 | Official OpenVINO Model Server |

## Conversion Requirements

The main conversion flow exports the original Hugging Face model to OpenVINO IR with INT4 weight compression. Prepare enough memory and disk space before running conversion.

| Model | Recommended RAM | Recommended Free Disk | Note |
| --- | --- | --- | --- |
| Gemma 4 E2B | 32 GB or higher | 60 GB or higher | Validated example |
| Gemma 4 E4B | 64 GB or higher | 100 GB or higher | Not validated in this test round |
| Gemma 4 26B-A4B | High-memory conversion machine | 200 GB or higher | Not validated in this test round |
| Gemma 4 31B | High-memory conversion machine | 250 GB or higher | Not validated in this test round |

Important:

```text
Gemma 4 conversion uses preview/nightly OpenVINO packages from the official notebook.
Use a higher-memory development/conversion machine for larger models.
After conversion, copy the converted OpenVINO folder to the edge device.
NPU is not covered by this guide.
```

The validated conversion environment installs the packages from the official OpenVINO Gemma4 notebook:

```text
optimum-intel from GitHub
openvino-genai / openvino / openvino-tokenizers / nncf with --pre and OpenVINO nightly wheel index
transformers==5.5.0
torch>=2.10
torchvision
Pillow
gradio>=6.0
opencv-python
requests
matplotlib
```

Validated package versions:

```text
torch 2.12.1+cpu
transformers 5.5.0
openvino 2026.3.0.dev20260703
openvino-genai 2026.3.0.dev20260703
openvino-tokenizers 2026.3.0.dev20260703
nncf 3.2.0
optimum-intel 2.1.0.dev0
optimum 2.2.0
```

# Model Preparation

## CPU / iGPU Model

CPU and iGPU use the OpenVINO INT4 model converted by this guide.

| Method | Source | Default Model Path | Note |
| --- | --- | --- | --- |
| Convert from original model | `google/gemma-4-E2B-it` | `C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official` | Validated example |

To try a larger model, replace the model id and output folder in the commands:

```text
google/gemma-4-E4B-it
google/gemma-4-26B-A4B-it
google/gemma-4-31B-it
```

The converted model is intended for CPU and iGPU OVMS runs:

```text
--target_device CPU
--target_device GPU
```

## NPU Model

NPU is not supported in this guide.

Gemma 4 is not validated for NPU here, and no NPU script is provided.

## Hugging Face Access

Gemma models may require Hugging Face authentication and accepted access terms.

Before downloading:

1. Sign in to Hugging Face.
2. Open the model repository page and accept the required access terms if prompted.
3. Log in from the command line after the Python environment is created.

Interactive login:

```bat
set "PYTHONIOENCODING=utf-8"
C:\Advantech\GenAI\envs\gemma4_official_convert\Scripts\hf.exe auth login
```

Token environment variable:

```bat
set "HF_TOKEN=hf_your_token_here"
```

# Script Workflow

The existing Gemma 4 scripts are located in:

```text
ai_sdk\intel\openvino\2026_1\script\genai\gemma4_series
```

Current script list:

| Script | Purpose |
| --- | --- |
| `00_config.bat` | Existing common paths, model id, output folders, OVMS path, and port |
| `01_check_env.bat` | Existing environment check |
| `02_prepare_workspace.bat` | Existing workspace setup |
| `03_prepare_convert_env.bat` | Existing conversion environment setup |
| `04_download_raw_model.bat` | Existing raw model download |
| `05_convert_openvino_int4.bat` | Existing Python conversion script |
| `06_check_converted_model.bat` | Existing converted model check |
| `07_check_ovms.bat` | Checks `ovms.exe` |
| `08_run_ovms_cpu.bat` | Starts OVMS on CPU |
| `09_run_ovms_igpu.bat` | Starts OVMS on iGPU |
| `10_chat.bat` | Sends a test prompt to OVMS |

Important: the validated E2B conversion used the official notebook package environment and `optimum-cli export openvino`. The existing `03_prepare_convert_env.bat` and `05_convert_openvino_int4.bat` are not the validated conversion path yet.

## Configuration

The validated example uses these paths:

| Variable | Value |
| --- | --- |
| `CONDA_ROOT` | `C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3` |
| `WORKSPACE` | `C:\Advantech\GenAI` |
| `ENV_PATH` | `C:\Advantech\GenAI\envs\gemma4_official_convert` |
| `MODEL_ID` | `google/gemma-4-E2B-it` |
| `RAW_MODEL` | `C:\Advantech\GenAI\models\gemma4_e2b_test\raw_model` |
| `OV_MODEL` | `C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official` |
| `OV_MODEL_NAME` | `gemma-4-e2b-it-int4` |
| `REST_PORT` | `23953` |

If the Edge AI SDK product already includes OVMS, the scripts also check:

```text
C:\Program Files\Advantech\EdgeAI\System\Intel\GenAI\app\engine\intel\scripts\ovms_2026_2\ovms.exe
```

## Quick Start

Open Command Prompt:

```bat
cd /d <repo>\ai_sdk\intel\openvino\2026_1
```

Create the official Gemma4 conversion environment:

```bat
"C:\Program Files\Advantech\EdgeAI\System\Intel\SDK\miniconda3\Scripts\conda.exe" create -p C:\Advantech\GenAI\envs\gemma4_official_convert python=3.11 -y
```

Install packages from the official Gemma4 notebook:

```bat
set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%PATH%"
set "PYTHONIOENCODING=utf-8"
set "PYTHON_EXE=C:\Advantech\GenAI\envs\gemma4_official_convert\python.exe"

"%PYTHON_EXE%" -m pip install --upgrade pip
"%PYTHON_EXE%" -m pip install "git+https://github.com/huggingface/optimum-intel.git" --extra-index-url https://download.pytorch.org/whl/cpu
"%PYTHON_EXE%" -m pip install -U --pre "openvino-genai" "openvino" "openvino-tokenizers" "nncf" --extra-index-url https://storage.openvinotoolkit.org/simple/wheels/nightly
"%PYTHON_EXE%" -m pip install "transformers==5.5.0"
"%PYTHON_EXE%" -m pip install "torch>=2.10" "torchvision" "Pillow" "gradio>=6.0" "opencv-python" "requests" "matplotlib" --extra-index-url https://download.pytorch.org/whl/cpu
```

Log in to Hugging Face if required:

```bat
C:\Advantech\GenAI\envs\gemma4_official_convert\Scripts\hf.exe auth login
```

Download the E2B raw model:

```bat
C:\Advantech\GenAI\envs\gemma4_official_convert\python.exe -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='google/gemma-4-E2B-it', local_dir=r'C:\Advantech\GenAI\models\gemma4_e2b_test\raw_model')"
```

Convert to OpenVINO INT4:

```bat
C:\Advantech\GenAI\envs\gemma4_official_convert\Scripts\optimum-cli.exe export openvino ^
  --model C:\Advantech\GenAI\models\gemma4_e2b_test\raw_model ^
  --task image-text-to-text ^
  C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official ^
  --weight-format int4
```

## Download and Convert

The validated conversion command is:

```bat
C:\Advantech\GenAI\envs\gemma4_official_convert\Scripts\optimum-cli.exe export openvino ^
  --model C:\Advantech\GenAI\models\gemma4_e2b_test\raw_model ^
  --task image-text-to-text ^
  C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official ^
  --weight-format int4
```

Expected converted output files:

```text
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\config.json
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\generation_config.json
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\openvino_language_model.xml
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\openvino_language_model.bin
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\openvino_text_embeddings_model.xml
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\openvino_text_embeddings_model.bin
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\openvino_text_embeddings_per_layer_model.xml
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\openvino_text_embeddings_per_layer_model.bin
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\openvino_vision_embeddings_model.xml
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\openvino_vision_embeddings_model.bin
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\openvino_tokenizer.xml
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\openvino_detokenizer.xml
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\tokenizer.json
C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official\processor_config.json
```

Validated CPU load test:

```python
import openvino_genai as ov_genai

model_dir = r"C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official"
pipe = ov_genai.VLMPipeline(model_dir, "CPU")
result = pipe.generate("Answer in one sentence: what is OpenVINO?", max_new_tokens=32)
print(result)
```

Important notes:

* The official notebook package combination installs preview/nightly OpenVINO packages.
* `optimum-intel` may print a dependency warning about `transformers==5.5.0`; this was also present in the validated environment and did not block E2B conversion.
* `hf.exe auth login` should be run with `PYTHONIOENCODING=utf-8` on Windows consoles to avoid Unicode output issues.
* `conda create` may print `SafetyError` from the EdgeAI SDK Miniconda package cache. If `python.exe` is created successfully, continue package installation.
* Larger Gemma 4 models require more memory, disk space, and time. Validate them on a high-memory conversion machine.

# Deploy

## Prepare OVMS

Download OVMS 2026.2.0 from official OpenVINO Model Server releases:

```text
https://github.com/openvinotoolkit/model_server/releases
https://storage.openvinotoolkit.org/repositories/openvino_model_server/packages/2026.2.0/
```

Download the Windows x64 package that contains `ovms.exe`, extract it to:

```text
C:\Advantech\GenAI\ovms
```

Then verify:

```bat
script\genai\gemma4_series\07_check_ovms.bat
```

If the extracted folder is different, set the actual OVMS path before running scripts:

```bat
set "OVMS_EXE=C:\Advantech\GenAI\ovms\ovms.exe"
```

## Run OVMS

Open one Command Prompt for OVMS and run one target device.

The existing OVMS scripts use values from `00_config.bat`. If you use the validated E2B output path, set the model variables before running OVMS:

```bat
set "OV_MODEL=C:\Advantech\GenAI\models\gemma4_e2b_test\openvino_int4_official"
set "OV_MODEL_NAME=gemma-4-e2b-it-int4"
```

CPU:

```bat
script\genai\gemma4_series\08_run_ovms_cpu.bat
```

iGPU:

```bat
script\genai\gemma4_series\09_run_ovms_igpu.bat
```

Keep the OVMS Command Prompt open. Open another Command Prompt to run the chat client.

## Run Chat Client

After OVMS starts successfully, set the same model name and run:

```bat
set "OV_MODEL_NAME=gemma-4-e2b-it-int4"
script\genai\gemma4_series\10_chat.bat
```

# Result

OVMS example:

![result](/assets/intel/ovms.png)

Chat client example:

![result](/assets/intel/chatbot.png)

| Device | Model | OVMS Script | Chat Script | Expected Status |
| --- | --- | --- | --- | --- |
| CPU | `gemma-4-e2b-it-int4` | `08_run_ovms_cpu.bat` | `10_chat.bat` | Expected after successful conversion |
| iGPU | `gemma-4-e2b-it-int4` | `09_run_ovms_igpu.bat` | `10_chat.bat` | Expected after successful conversion |
| NPU | `gemma-4-e2b-it-int4` | Not provided | Not provided | Not supported in this guide |

# Reference

* OpenVINO Gemma4 notebook: https://github.com/openvinotoolkit/openvino_notebooks/tree/latest/notebooks/gemma4
* Gemma 4 E2B Hugging Face model: https://huggingface.co/google/gemma-4-E2B-it
* OpenVINO Model Server releases: https://github.com/openvinotoolkit/model_server/releases
* Running Gemma 4 with OpenVINO: https://medium.com/openvino-toolkit/running-gemma-4-with-openvino-building-a-multimodal-assistant-end-to-end-37a9ce74f0ca
* OpenVINO documentation: https://docs.openvino.ai/
