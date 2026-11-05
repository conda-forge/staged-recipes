#!/usr/bin/env python3
"""Copy ppt-master skill into the current project's .claude/skills/ directory."""
import argparse
import os
import shutil
import sys


def main():
    parser = argparse.ArgumentParser(
        description="Install ppt-master skill into .claude/skills/",
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

    source = os.path.join(prefix, "share", "ppt-master", "skills", "ppt-master")
    if not os.path.isdir(source):
        print(f"Error: skill not found at {source}", file=sys.stderr)
        sys.exit(1)

    dest = args.dest
    os.makedirs(dest, exist_ok=True)

    dst = os.path.join(dest, "ppt-master")
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(source, dst)

    print(f"Installed ppt-master skill to '{dst}'.")


if __name__ == "__main__":
    main()
