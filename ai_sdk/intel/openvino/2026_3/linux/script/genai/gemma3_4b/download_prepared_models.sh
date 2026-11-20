#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

fetch_model() (
    local repo=$1 revision=$2 destination=$3 file url stage
    url=https://huggingface.co/Advantech-EIOT/$repo/resolve/$revision
    stage=$(mktemp -d "$MODEL_ROOT/.gemma.XXXXXXXX")
    trap 'rm -rf -- "$stage"' EXIT
    for file in config.json generation_config.json openvino_config.json \
        added_tokens.json chat_template.jinja preprocessor_config.json processor_config.json \
        special_tokens_map.json tokenizer_config.json tokenizer.json tokenizer.model \
        openvino_detokenizer.xml openvino_detokenizer.bin openvino_tokenizer.xml openvino_tokenizer.bin \
        openvino_text_embeddings_model.xml openvino_text_embeddings_model.bin \
        openvino_vision_embeddings_model.xml openvino_vision_embeddings_model.bin \
        openvino_language_model.xml openvino_language_model.bin; do
        curl --fail --location --retry 4 --connect-timeout 15 --max-time 1200 "$url/$file" -o "$stage/$file"
    done
    "$HERE/06_check_converted_model.sh" "$stage"
    mkdir -p -- "$destination"
    cp -- "$stage/"* "$destination/"
    printf 'Prepared model: %s\n' "$destination"
)

mkdir -p -- "$MODEL_ROOT"
case "${1:-all}" in
    cpu|npu|all) target=${1:-all} ;;
    *) echo 'Use cpu, npu, or all.' >&2; exit 2 ;;
esac
if [[ $target == cpu || $target == all ]]; then
    fetch_model intel_google-gemma-3-4b-it-int4 f6d934fa4caf62db9f1290d89c6269dfb96f9b12 "$PREPARED_CPU_PATH"
fi
if [[ $target == npu || $target == all ]]; then
    fetch_model intel_google-gemma-3-4b-it-int4-cw-ov e3d5536c0cfc2380168b088527fe1c1aed8d5972 "$NPU_MODEL_PATH"
fi
