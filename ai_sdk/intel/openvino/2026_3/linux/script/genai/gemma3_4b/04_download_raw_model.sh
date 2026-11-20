#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

test -x "$ENV_PATH/bin/hf" || { echo 'Run 03_prepare_convert_env.sh first.' >&2; exit 1; }
"$ENV_PATH/bin/hf" download "$RAW_MODEL_ID" --local-dir "$RAW_MODEL_PATH"
