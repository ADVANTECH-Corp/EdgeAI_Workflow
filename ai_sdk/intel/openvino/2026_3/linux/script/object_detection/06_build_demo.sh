#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

ov_cmake=$("$BUILD_ENV/bin/python" -c 'from pathlib import Path; import openvino; print(Path(openvino.__file__).parent / "cmake")')
test -f "$ov_cmake/OpenVINOConfig.cmake"
cmake -S "$OMZ_DIR/demos" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DOpenVINO_DIR="$ov_cmake"
cmake --build "$BUILD_DIR" --target object_detection_demo --parallel "${BUILD_JOBS:-2}"
test -x "$APP_EXE"
printf '%s\n' "$APP_EXE"
