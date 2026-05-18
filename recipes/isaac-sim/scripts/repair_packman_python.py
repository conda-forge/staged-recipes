from __future__ import annotations

import argparse
import os
from pathlib import Path


def repair_broken_dynload_links(root: Path, python_mm: str) -> None:
    dynload_root = root / "_build" / "target-deps" / "python" / "lib" / f"python{python_mm}" / "lib-dynload"
    pm_packages_root = Path(os.environ.get("PM_PACKAGES_ROOT", ""))
    kit_kernel_root = pm_packages_root / "chk" / "kit-kernel"

    if not dynload_root.is_dir() or not kit_kernel_root.is_dir():
        return

    marker = f"/python/lib/python{python_mm}/"
    for link_path in kit_kernel_root.rglob("*.so"):
        if not link_path.is_symlink() or link_path.exists() or marker not in str(link_path):
            continue

        replacement = dynload_root / link_path.name
        if replacement.is_file():
            link_path.unlink(missing_ok=True)
            link_path.symlink_to(replacement)


def patch_cpp_wrappers(root: Path, isaac_platform: str) -> None:
    cpp_wrappers = (
        root
        / "_build"
        / isaac_platform
        / "release"
        / "kit"
        / "dev"
        / "include"
        / "omni"
        / "graph"
        / "core"
        / "CppWrappers.h"
    )
    if not cpp_wrappers.is_file():
        return

    text = cpp_wrappers.read_text()
    updated = text.replace(
        "HandleInt* namesPtr = reinterpret_cast<HandleInt*>(inTuplePtr);",
        "NameToken* namesPtr = reinterpret_cast<NameToken*>(inTuplePtr);",
    )
    if updated != text:
        cpp_wrappers.write_text(updated)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    parser.add_argument("--python-mm", required=True)
    parser.add_argument("--isaac-platform", required=True)
    args = parser.parse_args()

    root = Path(args.root)
    repair_broken_dynload_links(root, args.python_mm)
    patch_cpp_wrappers(root, args.isaac_platform)


if __name__ == "__main__":
    main()
