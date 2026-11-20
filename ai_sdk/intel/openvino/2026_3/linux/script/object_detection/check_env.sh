#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

for command in git curl cmake g++ "$PYTHON_BIN"; do
    command -v "$command"
done
cmake --version
if ! command -v uv >/dev/null; then
    echo 'Install uv before running the original-model conversion steps.'
fi
test -r "$OV_RUNTIME/libopenvino.so.2630"
printf 'Workspace: %s\nOpenVINO runtime: %s\n' "$WORKSPACE" "$OV_RUNTIME"
