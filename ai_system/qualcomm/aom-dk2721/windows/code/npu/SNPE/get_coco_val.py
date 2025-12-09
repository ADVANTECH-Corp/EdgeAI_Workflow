#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os, random
from pathlib import Path
from typing import Tuple

import fiftyone as fo
import fiftyone.zoo as foz
import fiftyone.core.labels as fol
import fiftyone.core.fields as fof
from PIL import Image, ImageOps

# ===================== Adjustable Parameters =====================
SEED = 123
TARGET_CLASSES = []  
TOTAL_SAMPLES = 1000                         # Number of images to generate
NEGATIVE_RATIO = 0                           # Ratio of negative samples (0~0.5)
IMG_SIZE = (320, 320)                        # Target size (h, w)
PAD_COLOR = (114, 114, 114)                  # Common padding color for YOLO
OUT_DIR = "quant_imgs_320"                   # Output image directory
DATASET_ZOO_DIR = "Downloaded_file"          # FiftyOne cache directory
IMG_FORMAT = "jpg"                           # Output format: jpg/png
JPEG_QUALITY = 95                            # JPEG optimization quality
# =================================================================

# (Optional) Disable legacy MongoDB validation prompt
fo.config.database_validation = False

def letterbox_pil(im: Image.Image, new_shape: Tuple[int, int], color=(114,114,114)):
    """
    Resize uniformly to fit the longest side, then pad with specified color to new_shape (h,w).
    """
    h0, w0 = im.height, im.width
    r = min(new_shape[0] / h0, new_shape[1] / w0)
    new_unpad = (int(round(w0 * r)), int(round(h0 * r)))  # (w, h)
    im = im.resize(new_unpad, Image.BILINEAR)
    dw = new_shape[1] - new_unpad[0]
    dh = new_shape[0] - new_unpad[1]
    left, right = dw // 2, dw - dw // 2
    top, bottom = dh // 2, dh - dh // 2
    im = ImageOps.expand(im, border=(left, top, right, bottom), fill=color)
    return im

def find_detections_field(ds: fo.Dataset) -> str:
    """
    Automatically find the Detections field name (e.g., ground_truth / detections).
    """
    schema = ds.get_field_schema()
    for name, field in schema.items():
        if isinstance(field, fof.EmbeddedDocumentField) and issubclass(
            field.document_type, fol.Detections
        ):
            return name
    raise RuntimeError("Cannot find Detections field, please check the dataset")

def main():
    random.seed(SEED)
    fo.config.dataset_zoo_dir = os.path.join(os.getcwd(), DATASET_ZOO_DIR)

    # Determine if we are filtering specific classes or using all classes
    use_specific_classes = len(TARGET_CLASSES) > 0
    
    classes_arg = list(set(TARGET_CLASSES)) if use_specific_classes else None
    mode_str = f"Specific Classes: {classes_arg}" if use_specific_classes else "ALL Classes (80)"
    print(f"[1/4] Loading COCO-2017 val ... [{mode_str}]")

    dataset = foz.load_zoo_dataset(
        "coco-2017",
        split="validation",
        label_types=["detections"],
        classes=classes_arg, # Pass None if we want all classes
        max_samples=None,
    )
    det_field = find_detections_field(dataset)

    print("[2/4] Building positive/negative pools ...")
    
    if use_specific_classes:
        # Filter: Image MUST contain at least one object from TARGET_CLASSES
        pos_view = dataset.filter_labels(
            det_field,
            fo.ViewField("label").is_in(TARGET_CLASSES),
            only_matches=True,
        )
    else:
        # Filter: Image MUST contain at least one detection of ANY class
        # (COCO val usually has detections, but this ensures no empty images)
        pos_view = dataset.match(
            fo.ViewField(det_field + ".detections").length() > 0
        )

    pos_ids = [s.id for s in pos_view]

    # Negatives: Exclude positive samples
    # Note: If TARGET_CLASSES is [], 'pos_view' is basically the whole dataset, 
    # so 'neg_view' will likely be empty.
    full_dataset = foz.load_zoo_dataset(
        "coco-2017", split="validation", label_types=["detections"], max_samples=None
    )
    _ = find_detections_field(full_dataset)
    neg_view = full_dataset.exclude(pos_ids)

    num_pos_need = int(TOTAL_SAMPLES * (1 - NEGATIVE_RATIO))
    num_neg_need = TOTAL_SAMPLES - num_pos_need

    print(f"   pool sizes -> Pos: {len(pos_view)}, Neg: {len(neg_view)}")
    
    if len(pos_view) < num_pos_need:
        print(f"   [WARN] Not enough positive samples! (Request: {num_pos_need}, Available: {len(pos_view)})")
        num_pos_need = len(pos_view)

    if len(neg_view) < num_neg_need:
        if num_neg_need > 0:
            print(f"   [WARN] Not enough negative samples! (Request: {num_neg_need}, Available: {len(neg_view)})")
        num_neg_need = len(neg_view)

    # Legacy FiftyOne take() has no shuffle, so use Python randomization
    pos_samples = list(pos_view.take(num_pos_need, seed=SEED))
    neg_samples = list(neg_view.take(num_neg_need, seed=SEED + 1))

    filepaths = [s.filepath for s in pos_samples] + [s.filepath for s in neg_samples]
    random.shuffle(filepaths)

    out_dir = Path(OUT_DIR)
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"[3/4] Saving letterboxed images ({IMG_SIZE[0]}x{IMG_SIZE[1]}) ...")
    saved, failed = 0, 0
    out_paths = []
    for p in filepaths:
        try:
            img = Image.open(p).convert("RGB")
            img = letterbox_pil(img, IMG_SIZE, PAD_COLOR)
            out_path = out_dir / (Path(p).stem + f"_{IMG_SIZE[0]}x{IMG_SIZE[1]}." + IMG_FORMAT)
            if IMG_FORMAT.lower() in ("jpg", "jpeg"):
                img.save(out_path, format="JPEG", quality=JPEG_QUALITY, optimize=True)
            else:
                img.save(out_path)
            out_paths.append(str(out_path))
            saved += 1
        except Exception as e:
            failed += 1
            print(f"  [WARN] {Path(p).name} -> fail: {e}")


    print("\nDone.")
    print(f"Saved: {saved}, Failed: {failed}")
    print(f"Output dir: {out_dir.resolve()}")


if __name__ == "__main__":
    main()