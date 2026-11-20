#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$HERE/00_config.sh"

case "${1:?Specify cpu or npu.}" in
    cpu) model=$CPU_MODEL_ID ;;
    npu) model=$NPU_MODEL_ID ;;
    *) echo 'Specify cpu or npu.' >&2; exit 2 ;;
esac

url=$OVMS_URL/v1/chat/completions

request_chat() {
    curl --fail-with-body --silent --show-error --max-time 180 "$url" \
        -H 'Content-Type: application/json' --data "$1"
}

case "${2:-}" in
    '')
        request_chat "{\"model\":\"$model\",\"messages\":[{\"role\":\"user\",\"content\":\"What is 2 + 2? Reply briefly.\"}],\"max_tokens\":24}"
        printf '\n'
        exit 0
        ;;
    --interactive) ;;
    *) echo 'Supported option: --interactive' >&2; exit 2 ;;
esac

command -v jq >/dev/null || { echo 'Install jq to use interactive chat.' >&2; exit 1; }

printf '[INFO] URL  : %s\n[INFO] Model: %s\n' "$url" "$model"
printf '[INFO] Type a prompt and press Enter. Type exit to quit.\n'

while IFS= read -e -r -p $'\nYou> ' prompt; do
    case "$prompt" in
        exit|quit) break ;;
        '') continue ;;
    esac
    payload=$(jq -cn --arg model "$model" --arg prompt "$prompt" \
        '{model: $model, messages: [{role: "user", content: $prompt}], max_tokens: 128, temperature: 0}')
    if response=$(request_chat "$payload") &&
        answer=$(jq -er '.choices[0].message.content | strings | select(length > 0)' <<< "$response"); then
        printf 'Assistant> %s\n' "$answer"
    else
        printf '[ERROR] No answer received from OVMS.\n' >&2
        if [[ -n $response ]]; then printf '%s\n' "$response" >&2; fi
    fi
done
