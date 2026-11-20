#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

docker info --format 'Docker server: {{.ServerVersion}}'
if ! docker image inspect "$OVMS_IMAGE" >/dev/null 2>&1; then docker pull "$OVMS_IMAGE"; fi
docker image inspect "$OVMS_IMAGE" --format '{{join .RepoDigests ", "}}'
