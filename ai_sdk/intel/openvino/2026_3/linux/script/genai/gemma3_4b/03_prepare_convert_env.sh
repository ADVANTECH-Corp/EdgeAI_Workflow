#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

mkdir -p -- "$WORKSPACE/envs"
uv venv --python 3.11 "$ENV_PATH"
uv pip install --python "$ENV_PATH/bin/python" --index-url https://download.pytorch.org/whl/cpu \
    'torch==2.7.1' 'torchvision==0.22.1'
uv pip install --python "$ENV_PATH/bin/python" \
    'optimum-intel[openvino]==2.1.0' 'openvino==2026.3.0' 'openvino-genai==2026.3.0' \
    huggingface_hub pillow
