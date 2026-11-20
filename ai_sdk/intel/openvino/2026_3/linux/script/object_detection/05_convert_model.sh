#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

"$CONVERT_ENV/bin/omz_converter" --name "${1:-ssd_mobilenet_v1_coco}" \
    --download_dir "$MODEL_DIR" --output_dir "$MODEL_DIR" --precisions FP16 \
    --mo "$CONVERT_ENV/bin/mo" --python "$CONVERT_ENV/bin/python"
