#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

test -s "$RAW_MODEL_PATH/config.json" || { echo 'Download the original Gemma model first.' >&2; exit 1; }
export TMPDIR="${TMPDIR:-$WORKSPACE/tmp}"
mkdir -p -- "$TMPDIR"
"$ENV_PATH/bin/optimum-cli" export openvino --model "$RAW_MODEL_PATH" \
    --task image-text-to-text --weight-format int4 "$CPU_IGPU_MODEL_PATH"
