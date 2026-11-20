#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

mkdir -p -- "$WORKSPACE/envs" "$MODEL_DIR" "$BUILD_DIR"
if [[ ! -d $OMZ_DIR/.git ]]; then
    git init --quiet "$OMZ_DIR"
fi
if ! revision=$(git -C "$OMZ_DIR" rev-parse --verify HEAD 2>/dev/null); then
    git -C "$OMZ_DIR" fetch --depth 1 https://github.com/openvinotoolkit/open_model_zoo.git "$OMZ_REF"
    git -C "$OMZ_DIR" checkout --detach FETCH_HEAD
    revision=$(git -C "$OMZ_DIR" rev-parse HEAD)
fi
[[ $revision == "$OMZ_REF" ]] || { printf 'Expected OMZ commit %s in %s\n' "$OMZ_REF" "$OMZ_DIR" >&2; exit 1; }
git -C "$OMZ_DIR" submodule update --init --depth 1 -- demos/thirdparty/gflags
