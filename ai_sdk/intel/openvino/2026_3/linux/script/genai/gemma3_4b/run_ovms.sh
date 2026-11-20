#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

target=${1:?Specify CPU, GPU or NPU.}
model=$CPU_IGPU_MODEL_PATH
model_id=$CPU_MODEL_ID
device_args=()
extra_args=(--cache_size 1)
case "$target" in
    CPU) ;;
    GPU)
        [[ -c $GPU_NODE ]] || { printf 'Missing GPU device: %s\n' "$GPU_NODE" >&2; exit 1; }
        device_args=(--device /dev/dri:/dev/dri --group-add "$(stat -c %g "$GPU_NODE")")
        ;;
    NPU)
        [[ -c $NPU_NODE ]] || { printf 'Missing NPU device: %s\n' "$NPU_NODE" >&2; exit 1; }
        device_args=(--device /dev/accel:/dev/accel --group-add "$(stat -c %g "$NPU_NODE")")
        model=$NPU_MODEL_PATH
        model_id=$NPU_MODEL_ID
        extra_args=(--cache_size 0 --enable_prefix_caching false)
        ;;
    *) echo 'Specify CPU, GPU or NPU.' >&2; exit 2 ;;
esac
"$HERE/06_check_converted_model.sh" "$model"
model=$(realpath -e -- "$model")
[[ ! -e $model/graph.pbtxt ]] ||
    { echo 'Use a model directory without graph.pbtxt so OVMS can configure the chosen device.' >&2; exit 1; }
if docker container inspect "$OVMS_CONTAINER" >/dev/null 2>&1; then
    printf 'Container %s exists. Remove it before switching devices.\n' "$OVMS_CONTAINER" >&2
    exit 1
fi
cache=$WORKSPACE/cache/$target
mkdir -p -- "$cache"
cache=$(realpath -e -- "$cache")
docker run --detach --name "$OVMS_CONTAINER" --user "$(id -u):$(id -g)" \
    --publish "127.0.0.1:$REST_PORT:8000" "${device_args[@]}" \
    --mount "type=bind,src=$model,dst=/model,readonly" --mount "type=bind,src=$cache,dst=/cache" \
    "$OVMS_IMAGE" --rest_port 8000 --rest_bind_address 0.0.0.0 --model_path /model \
    --task text_generation --pipeline_type VLM --model_name "$model_id" --target_device "$target" \
    --max_num_seqs 1 --max_num_batched_tokens 1024 --cache_dir /cache "${extra_args[@]}"
printf 'Service starting at %s/v1. Check docker logs %s before sending a request.\n' "$OVMS_URL" "$OVMS_CONTAINER"
