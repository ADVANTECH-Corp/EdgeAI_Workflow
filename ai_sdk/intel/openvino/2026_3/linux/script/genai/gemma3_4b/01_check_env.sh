#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

command -v curl
command -v docker
docker --version
docker info --format 'Docker server: {{.ServerVersion}}'
if ! command -v uv >/dev/null; then
    echo 'Install uv before running the original-model conversion steps.'
fi
printf 'Workspace: %s\nOVMS API: %s/v1\n' "$WORKSPACE" "$OVMS_URL"
for node in "$GPU_NODE" "$NPU_NODE"; do
    if [[ -c $node ]]; then stat -c '%n group=%G' "$node"; else printf 'Device unavailable: %s\n' "$node"; fi
done
