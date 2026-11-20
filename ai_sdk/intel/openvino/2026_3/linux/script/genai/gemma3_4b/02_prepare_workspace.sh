#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

mkdir -p -- "$MODEL_ROOT" "$WORKSPACE/envs" "$WORKSPACE/cache"
printf '%s\n' "$WORKSPACE"
