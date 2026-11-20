#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

"$CONVERT_ENV/bin/omz_downloader" --name "${1:-ssd_mobilenet_v1_coco}" --output_dir "$MODEL_DIR"
