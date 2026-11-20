#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

model=${1:-$CPU_IGPU_MODEL_PATH}
for name in language_model text_embeddings_model vision_embeddings_model tokenizer detokenizer; do
    for ext in xml bin; do
        file=$model/openvino_$name.$ext
        [[ -s $file ]] || { printf 'Missing model file: %s\n' "$file" >&2; exit 1; }
    done
done
test -s "$model/config.json"
printf 'Gemma 3 OpenVINO files present: %s\n' "$model"
