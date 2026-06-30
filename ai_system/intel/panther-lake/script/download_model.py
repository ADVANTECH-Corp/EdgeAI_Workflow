from __future__ import annotations

import argparse
from pathlib import Path

from huggingface_hub import snapshot_download


def main() -> int:
    parser = argparse.ArgumentParser(description="Download a Hugging Face model snapshot.")
    parser.add_argument("--repo-id", required=True, help="Hugging Face repository id.")
    parser.add_argument("--output", required=True, help="Local output folder.")
    parser.add_argument("--revision", default=None, help="Optional Hugging Face revision.")
    args = parser.parse_args()

    output = Path(args.output).expanduser().resolve()
    output.mkdir(parents=True, exist_ok=True)

    print(f"[INFO] Repo   : {args.repo_id}")
    print(f"[INFO] Output : {output}")
    path = snapshot_download(
        repo_id=args.repo_id,
        revision=args.revision,
        local_dir=str(output),
    )
    print(f"[INFO] Download complete: {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

