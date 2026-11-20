#!/usr/bin/env bash

WORKSPACE=${WORKSPACE:-$HOME/edgeai-workflow/gemma3_4b}
MODEL_ROOT=$WORKSPACE/models
ENV_PATH=$WORKSPACE/envs/gemma3_4b_convert
RAW_MODEL_ID=google/gemma-3-4b-it
RAW_MODEL_PATH=$MODEL_ROOT/gemma-3-4b-it-raw
CPU_IGPU_MODEL_PATH=${CPU_IGPU_MODEL_PATH:-$MODEL_ROOT/gemma-3-4b-it-converted-int4}
PREPARED_CPU_PATH=$MODEL_ROOT/gemma-3-4b-it-int4
NPU_MODEL_PATH=${NPU_MODEL_PATH:-$MODEL_ROOT/gemma-3-4b-it-int4-cw-ov}
CPU_MODEL_ID=gemma3-4b-int4
NPU_MODEL_ID=gemma3-4b-npu
OVMS_IMAGE=openvino/model_server:2026.4.1-gpu@sha256:a928903fe429f1e3e27107cc45932d30d95febfd2d1159dc50869c3eac76fc58
OVMS_CONTAINER=${OVMS_CONTAINER:-edgeai-workflow-gemma3}
REST_PORT=${REST_PORT:-18000}
OVMS_URL=http://127.0.0.1:$REST_PORT
GPU_NODE=${GPU_NODE:-/dev/dri/renderD128}
NPU_NODE=${NPU_NODE:-/dev/accel/accel0}
