#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

model=${1:?Specify ssd or yolo.}
device=${2:?Specify CPU, GPU or NPU.}
input=${3:-$DEMO_INPUT}
if [[ $input =~ ^/dev/video([0-9]+)$ ]]; then input=${BASH_REMATCH[1]}; fi
case "$device" in CPU|GPU|NPU) ;; *) echo 'Invalid OpenVINO device.' >&2; exit 2 ;; esac
case "$model" in
    ssd)
        ir=$MODEL_DIR/public/ssd_mobilenet_v1_coco/FP16/ssd_mobilenet_v1_coco.xml
        labels=$OMZ_DIR/data/dataset_classes/coco_91cl_bkgr.txt
        ;;
    yolo)
        case "${YOLO_SOURCE:-converted}" in
            converted) ir=$MODEL_DIR/public/yolo-v4-tf/FP16/yolo-v4-tf.xml ;;
            prepared) ir=$PREPARED_YOLO_DIR/yolo-v4-tf.xml ;;
            *) echo 'YOLO_SOURCE must be converted or prepared.' >&2; exit 2 ;;
        esac
        labels=$OMZ_DIR/data/dataset_classes/coco_80cl.txt
        ;;
    *) echo 'Specify ssd or yolo.' >&2; exit 2 ;;
esac
test -x "$APP_EXE" && test -s "$ir" && test -s "${ir%.xml}.bin" && test -s "$labels"
flags=(-loop)
if [[ ${DEMO_HEADLESS:-0} == 1 ]]; then
    flags=(-no_show)
fi
export LD_LIBRARY_PATH="$OV_RUNTIME${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$APP_EXE" -m "$ir" -at "$model" -d "$device" -i "$input" -labels "$labels" "${flags[@]}"
