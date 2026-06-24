from __future__ import annotations

import argparse
import json
import sys

import requests


def send_chat(url: str, model: str, prompt: str, max_tokens: int, temperature: float) -> str:
    payload = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": max_tokens,
        "temperature": temperature,
    }
    response = requests.post(url, json=payload, timeout=300)
    response.raise_for_status()
    data = response.json()
    return data["choices"][0]["message"]["content"]


def main() -> int:
    parser = argparse.ArgumentParser(description="Simple command-line chat client for OVMS /v3/chat/completions.")
    parser.add_argument("--url", default="http://127.0.0.1:23953/v3/chat/completions")
    parser.add_argument("--model", required=True)
    parser.add_argument("--max-tokens", type=int, default=128)
    parser.add_argument("--temperature", type=float, default=0.0)
    parser.add_argument("--once", default=None, help="Send one prompt and exit.")
    args = parser.parse_args()

    print(f"[INFO] URL  : {args.url}")
    print(f"[INFO] Model: {args.model}")

    if args.once:
        print(send_chat(args.url, args.model, args.once, args.max_tokens, args.temperature))
        return 0

    print("[INFO] Type a prompt and press Enter. Type exit to quit.")
    while True:
        try:
            prompt = input("\nYou> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            return 0
        if prompt.lower() in {"exit", "quit"}:
            return 0
        if not prompt:
            continue
        try:
            answer = send_chat(args.url, args.model, prompt, args.max_tokens, args.temperature)
            print(f"Assistant> {answer}")
        except Exception as exc:
            print(f"[ERROR] {exc}", file=sys.stderr)
            try:
                if hasattr(exc, "response") and exc.response is not None:
                    print(json.dumps(exc.response.json(), indent=2), file=sys.stderr)
            except Exception:
                pass


if __name__ == "__main__":
    raise SystemExit(main())

