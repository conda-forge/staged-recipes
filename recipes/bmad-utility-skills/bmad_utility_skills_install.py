#!/usr/bin/env python3
"""Copy bmad-utility-skills into the current project's .claude/skills/ directory."""
import argparse
import os
import shutil
import sys


def main():
    parser = argparse.ArgumentParser(
        description="Install bmad-utility-skills into .claude/skills/",
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
        print(
            "Error: CONDA_PREFIX is not set. Activate your pixi/conda environment first.",
            file=sys.stderr,
        )
        sys.exit(1)

    source = os.path.join(prefix, "share", "bmad-utility-skills", "skills")
    if not os.path.isdir(source):
        print(f"Error: bmad-utility-skills not found at {source}", file=sys.stderr)
        sys.exit(1)

    dest = args.dest
    os.makedirs(dest, exist_ok=True)

    installed = []
    for name in sorted(os.listdir(source)):
        src = os.path.join(source, name)
        if not os.path.isdir(src):
            continue
        dst = os.path.join(dest, name)
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
        installed.append(name)

    print(f"Installed {len(installed)} skill(s) to '{dest}':")
    for s in installed:
        print(f"  - {s}")
    if not installed:
        print("No skills were installed.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
