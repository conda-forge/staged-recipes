#!/usr/bin/env python3
"""Copy bmad-builder skills into the current project's .claude/skills/ directory."""
import argparse
import os
import shutil
import sys

SKILLS = [
    "bmad-agent-builder",
    "bmad-bmb-setup",
    "bmad-module-builder",
    "bmad-workflow-builder",
]


def main():
    parser = argparse.ArgumentParser(
        description="Install bmad-builder skills into .claude/skills/",
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

    source = os.path.join(prefix, "share", "bmad-builder", "skills")
    if not os.path.isdir(source):
        print(f"Error: bmad-builder skills not found at {source}", file=sys.stderr)
        sys.exit(1)

    dest = args.dest
    os.makedirs(dest, exist_ok=True)

    installed = []
    for skill in SKILLS:
        src = os.path.join(source, skill)
        dst = os.path.join(dest, skill)
        if not os.path.isdir(src):
            print(f"Warning: skill '{skill}' not found in package, skipping.")
            continue
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
        installed.append(skill)

    print(f"Installed {len(installed)} skill(s) to '{dest}':")
    for s in installed:
        print(f"  - {s}")
    if not installed:
        print("No skills were installed.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
