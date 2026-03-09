from __future__ import annotations

import argparse
import os
from pathlib import Path
import shutil


EXTENSION_DIRS = (
    (
        "usdrt.scenegraph-7.6.1+69cbf6ad.lx64.r.cp311",
        "usdrt.scenegraph",
    ),
    (
        "omni.graph.tools-1.79.2+69cbf6ad",
        "omni.graph.tools",
    ),
    (
        "omni.kit.asset_converter-5.0.17+107.3.1.lx64.r.cp311.u353",
        "omni.kit.asset_converter",
    ),
    (
        "omni.usd.core-1.5.3+69cbf6ad.lx64.r",
        "omni.usd.core",
    ),
    (
        "isaacsim.util.debug_draw-3.0.1+107.3.1.lx64.r.cp311",
        "isaacsim.util.debug_draw",
    ),
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--isaac-platform", required=True)
    return parser.parse_args()


def ensure_directory(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def materialize_directory(source: Path, destination: Path) -> None:
    if destination.exists():
        return
    if not source.is_dir():
        raise SystemExit(f"Missing staged extension directory: {source}")
    shutil.copytree(source, destination, symlinks=True)


def symlink_or_copy(target: Path, link_path: Path) -> None:
    if link_path.is_symlink() or link_path.exists():
        if link_path.is_dir() and not link_path.is_symlink():
            return
        link_path.unlink()
    try:
        os.symlink(target, link_path, target_is_directory=True)
    except OSError:
        # Fallback keeps the build working on filesystems that reject symlinks.
        if target.is_dir():
            ensure_directory(link_path.parent)
            if not link_path.exists():
                import shutil

                shutil.copytree(target, link_path, symlinks=True)


def main() -> None:
    args = parse_args()
    root = args.root.resolve()
    vendor_dir = root / "vendor" / "extscache"
    release_dir = root / "_build" / args.isaac_platform / "release"
    extscache_dir = release_dir / "extscache"
    extsbuild_dir = release_dir / "extsbuild"

    ensure_directory(extscache_dir)
    ensure_directory(extsbuild_dir)

    for extracted_name, link_name in EXTENSION_DIRS:
        source_dir = vendor_dir / extracted_name
        extracted_dir = extscache_dir / extracted_name
        materialize_directory(source_dir, extracted_dir)
        symlink_or_copy(extracted_dir, extsbuild_dir / link_name)


if __name__ == "__main__":
    main()
