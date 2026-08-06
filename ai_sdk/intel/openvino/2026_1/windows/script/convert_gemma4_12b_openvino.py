from __future__ import annotations

import argparse
from pathlib import Path

from optimum.intel import OVModelForVisualCausalLM, OVWeightQuantizationConfig
from transformers import AutoProcessor


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert Gemma 4 VLM to OpenVINO IR.")
    parser.add_argument("--model", required=True, help="Raw Hugging Face model folder or model id.")
    parser.add_argument("--output", required=True, help="OpenVINO output folder.")
    parser.add_argument("--precision", choices=("fp16", "int8", "int4"), default="int4")
    parser.add_argument("--trust-remote-code", action="store_true")
    args = parser.parse_args()

    output = Path(args.output).expanduser().resolve()
    output.mkdir(parents=True, exist_ok=True)

    quantization_config = None
    if args.precision == "int8":
        quantization_config = OVWeightQuantizationConfig(bits=8)
    elif args.precision == "int4":
        quantization_config = OVWeightQuantizationConfig(bits=4, sym=False, group_size=128, ratio=0.8)

    load_kwargs = {"trust_remote_code": args.trust_remote_code}
    model_kwargs = {**load_kwargs, "export": True}
    if quantization_config is not None:
        model_kwargs["quantization_config"] = quantization_config

    print(f"[INFO] Loading processor: {args.model}")
    processor = AutoProcessor.from_pretrained(args.model, **load_kwargs)

    print(f"[INFO] Exporting OpenVINO model: {output}")
    print(f"[INFO] Precision: {args.precision}")
    ov_model = OVModelForVisualCausalLM.from_pretrained(args.model, **model_kwargs)

    print("[INFO] Saving")
    ov_model.save_pretrained(output)
    processor.save_pretrained(output)
    print(f"[INFO] Done: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

