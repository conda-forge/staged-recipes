"""Check that ultrafast-pycocotools matches pycocotools on a small dataset.

The package's contract is bit-identical precision, recall and score arrays,
so the comparison is exact (np.array_equal), not approximate.
"""

import json
import os
import tempfile

import numpy as np
from pycocotools.coco import COCO as RefCOCO
from pycocotools.cocoeval import COCOeval as RefCOCOeval

from ultrafast_pycocotools import COCO, COCOeval


def polygon(x, y, w, h):
    return [[x, y, x + w, y, x + w, y + h, x + 0.3 * w, y + h]]


def make_data(seed=0):
    rng = np.random.default_rng(seed)
    images, anns, dets = [], [], []
    cats = [{"id": i, "name": f"c{i}"} for i in (1, 2, 3)]
    ann_id = 1
    for img_id in range(1, 21):
        images.append({"id": img_id, "width": 640, "height": 480})
        for _ in range(int(rng.integers(0, 6))):
            x, y = (float(v) for v in rng.uniform(0, 400, 2))
            w, h = (float(v) for v in rng.uniform(4, 200, 2))
            cat = int(rng.integers(1, 4))
            anns.append({
                "id": ann_id, "image_id": img_id, "category_id": cat,
                "bbox": [x, y, w, h], "area": w * h * 0.85,
                "segmentation": polygon(x, y, w, h),
                "iscrowd": int(rng.random() < 0.05),
            })
            ann_id += 1
            if rng.random() < 0.8:
                dx, dy = (float(v) for v in rng.normal(0, 0.1 * min(w, h), 2))
                dets.append({
                    "image_id": img_id, "category_id": cat,
                    "bbox": [x + dx, y + dy, w, h],
                    "segmentation": polygon(x + dx, y + dy, w, h),
                    "score": float(rng.random()),
                })
        for _ in range(int(rng.integers(0, 3))):
            x, y = (float(v) for v in rng.uniform(0, 400, 2))
            w, h = (float(v) for v in rng.uniform(4, 200, 2))
            dets.append({
                "image_id": img_id, "category_id": int(rng.integers(1, 4)),
                "bbox": [x, y, w, h], "segmentation": polygon(x, y, w, h),
                "score": float(rng.random()),
            })
    gt = {"info": {}, "images": images, "annotations": anns, "categories": cats}
    return gt, dets


def evaluate(coco_cls, eval_cls, gt_path, dets, iou_type):
    gt = coco_cls(gt_path)
    dt = gt.loadRes([dict(d) for d in dets])
    ev = eval_cls(gt, dt, iou_type)
    ev.evaluate()
    ev.accumulate()
    ev.summarize()
    return ev


def main():
    gt, dets = make_data()
    with tempfile.TemporaryDirectory() as tmp:
        gt_path = os.path.join(tmp, "gt.json")
        with open(gt_path, "w") as f:
            json.dump(gt, f)
        for iou_type in ("bbox", "segm"):
            ref = evaluate(RefCOCO, RefCOCOeval, gt_path, dets, iou_type)
            got = evaluate(COCO, COCOeval, gt_path, dets, iou_type)
            for key in ("precision", "recall", "scores"):
                assert np.array_equal(ref.eval[key], got.eval[key]), (iou_type, key)
            assert np.array_equal(ref.stats, got.stats), iou_type
            assert ref.stats[0] > 0, iou_type
    print("parity OK")


if __name__ == "__main__":
    main()
