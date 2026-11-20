#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
"$HERE/02_prepare_workspace.sh"
"$HERE/03_prepare_convert_env.sh"
"$HERE/04_download_raw_model.sh"
"$HERE/05_convert_openvino_int4.sh"
"$HERE/06_check_converted_model.sh"
