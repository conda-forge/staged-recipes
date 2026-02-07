#!/usr/bin/env python3
"""Test: dune binary path contamination check

Verifies dune binary doesn't contain build-time paths that could leak
from OCaml static libraries.

On macOS, stripping breaks code signature so path leakage is accepted.
On Linux, binaries should be stripped.
"""

import platform
import shutil
import subprocess
import sys


def main():
    print("=== Dune Path Contamination Tests ===")

    # Find dune binary
    dune_path = shutil.which("dune")
    if not dune_path:
        print("[FAIL] dune not found in PATH")
        return 1

    print(f"Binary: {dune_path}")

    is_macos = platform.system() == "Darwin"
    is_windows = platform.system() == "Windows"

    if is_windows:
        print("[OK] Path contamination check skipped on Windows")
        print("=== Path contamination tests passed ===")
        return 0

    # Use strings to check for build-time paths
    result = subprocess.run(
        ["strings", dune_path],
        capture_output=True,
        text=True,
        check=False,
    )

    contamination_patterns = [
        "rattler-build_",
        "conda-bld",
        "/home/conda",
        "/Users/runner",
    ]

    found_paths = []
    for line in result.stdout.split("\n"):
        for pattern in contamination_patterns:
            if pattern in line:
                found_paths.append(line[:100])  # Truncate long lines
                break

    if found_paths:
        print("  WARNING: Binary contains build-time paths (from OCaml static libraries)")
        for path in found_paths[:5]:
            print(f"    {path}")

        if is_macos:
            print("  (Accepted on macOS - stripping breaks code signature)")
            print("\n=== Path contamination tests passed ===")
            return 0
        else:
            print("[FAIL] Binary should be stripped on Linux")
            return 1
    else:
        print("[OK] No build-time path contamination")
        print("\n=== Path contamination tests passed ===")
        return 0


if __name__ == "__main__":
    sys.exit(main())
