#!/usr/bin/env python3
"""Install the bundled BMAD Dashboard .vsix into VS Code (or a compatible editor)."""
import argparse
import glob
import os
import shutil
import subprocess
import sys


def find_vsix(share_dir):
    matches = sorted(glob.glob(os.path.join(share_dir, "bmad-dashboard-*.vsix")))
    if not matches:
        return None
    return matches[-1]


def main():
    parser = argparse.ArgumentParser(
        description="Install the BMAD Dashboard .vsix into VS Code (or a compatible editor)",
        add_help=True,
    )
    parser.add_argument(
        "--cli",
        default="code",
        help="VS Code CLI binary to invoke (default: 'code'). Use 'code-insiders', "
        "'codium', or 'cursor' for compatible editors.",
    )
    parser.add_argument(
        "--vsix",
        default=None,
        help="Path to a specific .vsix file (default: the bundled one in CONDA_PREFIX/share/bmad-dashboard/)",
    )
    args = parser.parse_args()

    if args.vsix:
        vsix = args.vsix
        if not os.path.isfile(vsix):
            print(f"Error: --vsix path does not exist: {vsix}", file=sys.stderr)
            sys.exit(1)
    else:
        prefix = os.environ.get("CONDA_PREFIX", "")
        if not prefix:
            print(
                "Error: CONDA_PREFIX is not set. Activate your pixi/conda environment first, "
                "or pass --vsix.",
                file=sys.stderr,
            )
            sys.exit(1)
        share = os.path.join(prefix, "share", "bmad-dashboard")
        vsix = find_vsix(share)
        if not vsix:
            print(f"Error: no bmad-dashboard-*.vsix found in {share}", file=sys.stderr)
            sys.exit(1)

    cli = shutil.which(args.cli)
    if not cli:
        print(
            f"Error: '{args.cli}' CLI not found on PATH. Install VS Code (or your "
            "preferred compatible editor) and ensure its CLI is on PATH.",
            file=sys.stderr,
        )
        sys.exit(1)

    print(f"Installing {os.path.basename(vsix)} via {args.cli} ...")
    result = subprocess.run([cli, "--install-extension", vsix])
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
