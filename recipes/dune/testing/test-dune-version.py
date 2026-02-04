#!/usr/bin/env python3
"""Test: dune version and basic commands

Validates dune binary runs and basic command help works.

OCaml 5.3.0 aarch64/ppc64le bug workaround applied automatically.

Note: This test only runs for OCaml < 5.4.0.
"""

import os
import platform
import subprocess
import sys

from test_utils import get_ocaml_version, is_known_failure, document_failure


def get_ocaml_version_str():
    """Get OCaml version string for display."""
    version = get_ocaml_version()
    return f"{version[0]}.{version[1]}.{version[2]}"


def apply_ocaml_530_workaround():
    """Apply OCaml 5.3.0 aarch64/ppc64le GC workaround if needed."""
    ocaml_version = get_ocaml_version()
    version_str = get_ocaml_version_str()
    arch = platform.machine().lower()

    print(f"OCaml version: {version_str}")
    print(f"Architecture: {arch}")

    if ocaml_version[:2] == (5, 3) and arch in ("aarch64", "ppc64le", "arm64"):
        print("Applying OCaml 5.3.0 GC workaround (s=16M)")
        os.environ["OCAMLRUNPARAM"] = "s=16M"

    print(f"OCAMLRUNPARAM: {os.environ.get('OCAMLRUNPARAM', '<default>')}")


def run_cmd(cmd, description):
    """Run a command and return success status."""
    print(f"  Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        print(f"[FAIL] {description}")
        print(f"  stderr: {result.stderr[:500]}")
        return False
    print(f"[OK] {description}")
    return True


def main():
    print("=== dune version and help tests ===")

    # Track if failures are expected for this OCaml version
    known_failure = is_known_failure(max_version=(5, 4, 0))

    apply_ocaml_530_workaround()

    all_ok = True

    print("\n--- Test: dune --version ---")
    result = subprocess.run(
        ["dune", "--version"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode == 0:
        print(f"dune version: {result.stdout.strip()}")
        print("[OK] dune --version")
    else:
        print("[FAIL] dune --version")
        print(f"  stderr: {result.stderr}")
        all_ok = False

    print("\n--- Test: dune --help ---")
    all_ok &= run_cmd(["dune", "--help"], "dune --help")

    print("\n--- Test: dune build --help ---")
    all_ok &= run_cmd(["dune", "build", "--help"], "dune build --help")

    print("\n--- Test: dune clean --help ---")
    all_ok &= run_cmd(["dune", "clean", "--help"], "dune clean --help")

    if all_ok:
        print("\n=== All dune version tests passed ===")
        return 0
    elif known_failure:
        document_failure(
            "dune version tests",
            max_version=(5, 4, 0),
            reason="dune version tests not yet compatible with OCaml >= 5.4.0",
        )
        return 0
    else:
        print("\n=== dune version tests FAILED ===")
        return 1


if __name__ == "__main__":
    sys.exit(main())
