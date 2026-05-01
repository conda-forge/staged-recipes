#!/usr/bin/env python3
"""Install the ppt-master skill into the Claude Code skills directory."""
import argparse
import shutil
import sys
from pathlib import Path


def _update_claude_md(skill_dest: Path, no_claude_md: bool) -> None:
    if no_claude_md:
        print(f"\nSkipped CLAUDE.md update (--no-claude-md).")
        print(f"To enable the skill manually, add this line to ~/.claude/CLAUDE.md:")
        print(f"  @{skill_dest}/SKILL.md")
        return

    claude_md = Path.home() / ".claude" / "CLAUDE.md"
    ref_line = f"@{skill_dest}/SKILL.md"

    if claude_md.exists():
        content = claude_md.read_text(encoding="utf-8")
        if ref_line in content:
            print(f"\nCLAUDE.md already references the ppt-master skill.")
            return
        with claude_md.open("a", encoding="utf-8") as fh:
            if not content.endswith("\n"):
                fh.write("\n")
            fh.write(f"{ref_line}\n")
        print(f"\nAdded skill reference to {claude_md}")
    else:
        claude_md.parent.mkdir(parents=True, exist_ok=True)
        claude_md.write_text(f"{ref_line}\n", encoding="utf-8")
        print(f"\nCreated {claude_md} with skill reference.")

    print("Start a new Claude Code session to activate the skill.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Install the ppt-master skill for Claude Code",
        epilog=(
            "By default, also adds the skill reference to ~/.claude/CLAUDE.md "
            "so Claude Code picks it up automatically. Use --no-claude-md to skip."
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
    parser.add_argument(
        "--no-claude-md",
        action="store_true",
        help="Skip updating ~/.claude/CLAUDE.md",
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

    _update_claude_md(dest, args.no_claude_md)


if __name__ == "__main__":
    main()
