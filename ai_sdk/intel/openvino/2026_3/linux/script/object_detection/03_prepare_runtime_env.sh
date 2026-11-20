#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

test -r "$OV_RUNTIME/libopenvino.so.2630" ||
    { echo 'Install Edge AI SDK for Linux or configure OV_RUNTIME.' >&2; exit 1; }
"$PYTHON_BIN" -m venv "$BUILD_ENV"
"$BUILD_ENV/bin/python" -m pip install 'openvino==2026.3.0'
"$BUILD_ENV/bin/python" -c 'from pathlib import Path; import openvino; print(Path(openvino.__file__).parent / "cmake")'
