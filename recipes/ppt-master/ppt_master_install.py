#!/usr/bin/env python3
"""Install the ppt-master skill into the Claude Code skills directory."""
import argparse
import shutil
import sys
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Install the ppt-master skill for Claude Code",
        epilog=(
            "After installation, add the skill path to your Claude Code config "
            "or run 'claude skills add <dest>' if your version supports it."
        ),
    )
    parser.add_argument(
        "--dest",
        default=str(Path.home() / ".claude" / "skills" / "ppt-master"),
        help="Destination directory (default: ~/.claude/skills/ppt-master)",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite existing installation",
    )
    args = parser.parse_args()

    share_dir = Path(sys.prefix) / "share" / "ppt-master"
    if not share_dir.exists():
        print(
            f"Error: skill data not found at {share_dir}\n"
            "Re-install ppt-master via conda to restore the data.",
            file=sys.stderr,
        )
        sys.exit(1)

    dest = Path(args.dest)
    if dest.exists():
        if not args.force:
            print(
                f"Error: {dest} already exists. Use --force to overwrite.",
                file=sys.stderr,
            )
            sys.exit(1)
        shutil.rmtree(dest)

    shutil.copytree(str(share_dir), str(dest))
    print(f"ppt-master skill installed to {dest}")
    print(f"\nAdd to your CLAUDE.md or ~/.claude/CLAUDE.md:")
    print(f"  See {dest}/SKILL.md for usage instructions.")


if __name__ == "__main__":
    main()
