#!/usr/bin/env python3
"""Copy bmad-method-wds-expansion agents and workflows into .claude/skills/ directory."""
import argparse
import os
import shutil
import sys


def _copy_dir_contents(src_dir, dest_dir):
    """Copy each subdirectory of src_dir into dest_dir. Returns list of installed names."""
    installed = []
    if not os.path.isdir(src_dir):
        return installed
    for name in sorted(os.listdir(src_dir)):
        src = os.path.join(src_dir, name)
        dst = os.path.join(dest_dir, name)
        if not os.path.isdir(src):
            continue
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
        installed.append(name)
    return installed


def main():
    parser = argparse.ArgumentParser(
        description="Install bmad-wds agents and workflows into .claude/skills/",
        add_help=True,
    )
    parser.add_argument(
        "dest",
        nargs="?",
        default=os.path.join(".claude", "skills"),
        help="Destination directory (default: .claude/skills)",
    )
    args = parser.parse_args()

    prefix = os.environ.get("CONDA_PREFIX", "")
    if not prefix:
        print("Error: CONDA_PREFIX is not set. Activate your pixi/conda environment first.", file=sys.stderr)
        sys.exit(1)

    share = os.path.join(prefix, "share", "bmad-method-wds-expansion")
    if not os.path.isdir(share):
        print(f"Error: package data not found at {share}", file=sys.stderr)
        sys.exit(1)

    dest = args.dest
    os.makedirs(dest, exist_ok=True)

    installed = _copy_dir_contents(os.path.join(share, "agents"), dest)
    installed += _copy_dir_contents(os.path.join(share, "workflows"), dest)

    print(f"Installed {len(installed)} component(s) to '{dest}':")
    for s in installed:
        print(f"  - {s}")
    if not installed:
        print("No components were installed.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
