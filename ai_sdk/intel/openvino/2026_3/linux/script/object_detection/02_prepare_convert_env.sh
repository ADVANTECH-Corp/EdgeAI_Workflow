#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

mkdir -p -- "$WORKSPACE/envs"
uv venv --python 3.10 "$CONVERT_ENV"
uv pip install --python "$CONVERT_ENV/bin/python" \
    'openvino-dev==2024.6.0' 'tensorflow-cpu==2.15.1' 'numpy==1.26.4' 'opencv-python-headless==4.11.0.86'
