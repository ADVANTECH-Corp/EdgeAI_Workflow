#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
"$HERE/01_prepare_workspace.sh"
"$HERE/02_prepare_convert_env.sh"
"$HERE/03_prepare_runtime_env.sh"
"$HERE/04_download_model.sh"
"$HERE/05_convert_model.sh"
"$HERE/06_build_demo.sh"
