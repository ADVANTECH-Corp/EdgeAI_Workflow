#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

revision=b5165e2297d85ed898e1e11d0c3ec36a0e101ecc
url=https://huggingface.co/Advantech-EIOT/Intel_yolo-v4-tf_FP16/resolve/$revision
mkdir -p -- "$MODEL_DIR"
stage=$(mktemp -d "$MODEL_DIR/.yolo-v4.XXXXXXXX")
trap 'rm -rf -- "$stage"' EXIT
for file in yolo-v4-tf.xml yolo-v4-tf.bin LICENSE SHA256SUMS; do
    curl --fail --location --retry 4 --connect-timeout 15 --max-time 900 "$url/$file" -o "$stage/$file"
done
(cd "$stage" && sha256sum --strict -c SHA256SUMS)
mkdir -p -- "$PREPARED_YOLO_DIR"
cp -- "$stage/"* "$PREPARED_YOLO_DIR/"
printf 'Prepared model: %s\n' "$PREPARED_YOLO_DIR"
