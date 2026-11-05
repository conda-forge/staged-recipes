"""CLI entry point that installs the bundled .vsix into a local VS Code.

The conda package ships a single .vsix under ``bmad_dashboard.data``.  This
module locates that file, finds a VS Code variant on ``PATH``, and shells out
to ``<editor> --install-extension <vsix>``.  No VS Code is required at conda
install time; the user runs ``bmad-dashboard-install`` once after install to
wire the extension into their editor.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from importlib.resources import files
from pathlib import Path
from typing import Iterable

from . import EXTENSION_ID

DEFAULT_EDITORS: tuple[str, ...] = (
    "code",
    "code-insiders",
    "codium",
    "vscodium",
    "code-server",
)


def _bundled_vsix() -> Path:
    data_dir = files(__package__) / "data"
    candidates = [
        Path(str(entry))
        for entry in data_dir.iterdir()
        if entry.name.endswith(".vsix")
    ]
    if not candidates:
        raise FileNotFoundError(
            f"No .vsix found in {data_dir}. The conda package is malformed; "
            "please reinstall."
        )
    candidates.sort()
    return candidates[-1]


def _resolve_editor(preferred: str | None) -> str:
    if preferred:
        path = shutil.which(preferred)
        if path:
            return path
        raise FileNotFoundError(
            f"Requested editor {preferred!r} is not on PATH. Pass --editor-path "
            "with the absolute path to the CLI, or install the editor's shell "
            "command (in VS Code: Command Palette -> 'Shell Command: Install "
            "code command in PATH')."
        )
    for cmd in DEFAULT_EDITORS:
        path = shutil.which(cmd)
        if path:
            return path
    raise FileNotFoundError(
        "No VS Code CLI found on PATH. Tried: "
        + ", ".join(DEFAULT_EDITORS)
        + ". Install VS Code and ensure its shell command is on PATH, or pass "
        "--editor / --editor-path explicitly."
    )


def _run(cmd: Iterable[str]) -> int:
    cmd_list = list(cmd)
    print("$ " + " ".join(cmd_list), flush=True)
    return subprocess.call(cmd_list)


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="bmad-dashboard-install",
        description=(
            "Install the bundled BMAD Dashboard VS Code extension into a "
            "local VS Code (or Insiders, VSCodium, code-server) instance."
        ),
    )
    parser.add_argument(
        "--editor",
        help=(
            "Name of the VS Code CLI to use (looked up on PATH). "
            "Default: auto-detect among "
            + ", ".join(DEFAULT_EDITORS)
            + "."
        ),
    )
    parser.add_argument(
        "--editor-path",
        help="Absolute path to the VS Code CLI. Overrides --editor.",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List installed extensions in the detected editor and exit.",
    )
    parser.add_argument(
        "--uninstall",
        action="store_true",
        help=f"Uninstall {EXTENSION_ID} from the detected editor and exit.",
    )
    parser.add_argument(
        "--print-vsix",
        action="store_true",
        help="Print the bundled .vsix path and exit. Does not require an editor.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        default=True,
        help="Pass --force to the editor (default: on; the .vsix is reinstalled "
        "even when an equal or newer version is already present).",
    )
    parser.add_argument(
        "--no-force",
        dest="force",
        action="store_false",
        help="Do not pass --force; the editor will skip if the extension is "
        "already installed at an equal or newer version.",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)

    vsix = _bundled_vsix()

    if args.print_vsix:
        print(vsix)
        return 0

    if args.editor_path:
        editor = args.editor_path
        if not Path(editor).is_file():
            print(
                f"ERROR: --editor-path {editor!r} does not exist or is not a file.",
                file=sys.stderr,
            )
            return 2
    else:
        editor = _resolve_editor(args.editor)

    if args.list:
        return _run([editor, "--list-extensions", "--show-versions"])

    if args.uninstall:
        return _run([editor, "--uninstall-extension", EXTENSION_ID])

    cmd = [editor, "--install-extension", str(vsix)]
    if args.force:
        cmd.append("--force")
    rc = _run(cmd)
    if rc == 0:
        print(
            f"\nInstalled {EXTENSION_ID} from {vsix.name}. Reload the editor "
            "window or restart VS Code to activate the extension.",
            flush=True,
        )
    return rc


if __name__ == "__main__":
    sys.exit(main())
