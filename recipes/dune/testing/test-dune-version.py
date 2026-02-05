#!/usr/bin/env python3
"""Test: dune version and basic commands

Validates dune binary runs and basic command help works.

OCaml 5.3.0 aarch64/ppc64le bug workaround applied automatically.
Failures on OCaml <= 5.3.0 are documented as known bugs.
Failures on OCaml >= 5.4.0 are treated as real failures.
"""

import os
import subprocess
import sys

from test_utils import (
    get_ocaml_build_version,
    get_ocaml_build_version_str,
    get_target_arch,
    handle_test_result,
)


def apply_ocaml_530_workaround():
    """Apply OCaml 5.3.0 aarch64/ppc64le GC workaround if needed."""
    build_version = get_ocaml_build_version()
    version_str = get_ocaml_build_version_str()
    arch = get_target_arch()

    print(f"OCaml build version: {version_str}")
    print(f"Target architecture: {arch}")

    if build_version[:2] == (5, 3) and arch in ("aarch64", "ppc64le", "arm64"):
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

    # Use handle_test_result to properly handle known OCaml bugs
    # arch_sensitive=True because the GC bugs mainly affect aarch64/ppc64le
    return handle_test_result("dune version tests", all_ok, arch_sensitive=True)


if __name__ == "__main__":
    sys.exit(main())
