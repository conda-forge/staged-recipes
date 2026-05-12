#!/usr/bin/env python3
"""Copy the bmad-module-template tree into a target directory."""
import argparse
import os
import shutil
import sys

TEMPLATE_ENTRIES = [".claude-plugin", "skills", "docs", "README.md", "LICENSE"]


def main():
    parser = argparse.ArgumentParser(
        description="Scaffold a new BMad module from the template",
        add_help=True,
    )
    parser.add_argument(
        "dest",
        nargs="?",
        default=".",
        help="Destination directory (default: current directory)",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite existing files in the destination",
    )
    args = parser.parse_args()

    prefix = os.environ.get("CONDA_PREFIX", "")
    if not prefix:
        print(
            "Error: CONDA_PREFIX is not set. Activate your pixi/conda environment first.",
            file=sys.stderr,
        )
        sys.exit(1)

    source = os.path.join(prefix, "share", "bmad-module-template")
    if not os.path.isdir(source):
        print(f"Error: bmad-module-template not found at {source}", file=sys.stderr)
        sys.exit(1)

    dest = os.path.abspath(args.dest)
    os.makedirs(dest, exist_ok=True)

    copied = []
    for name in TEMPLATE_ENTRIES:
        src = os.path.join(source, name)
        dst = os.path.join(dest, name)
        if not os.path.exists(src):
            continue
        if os.path.exists(dst) and not args.force:
            print(f"Skipping (exists, use --force to overwrite): {name}")
            continue
        if os.path.isdir(src):
            if os.path.exists(dst):
                shutil.rmtree(dst)
            shutil.copytree(src, dst)
        else:
            shutil.copy2(src, dst)
        copied.append(name)

    print(f"Scaffolded BMad module template into: {dest}")
    if copied:
        print("Copied:")
        for n in copied:
            print(f"  - {n}")
    else:
        print("Nothing copied (use --force to overwrite existing files).", file=sys.stderr)
        sys.exit(1)

    print(
        "\nNext steps:\n"
        "  1. Rename skills/my-skill/ to your skill name (and add a SKILL.md).\n"
        "  2. Edit .claude-plugin/marketplace.json with your module info.\n"
        "  3. Replace placeholder LICENSE copyright with your name and year.\n"
        "  4. Replace this README with what your module does."
    )


if __name__ == "__main__":
    main()
