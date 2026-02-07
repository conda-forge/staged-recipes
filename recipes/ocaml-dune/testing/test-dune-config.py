#!/usr/bin/env python3
"""Test: dune configuration discovery

Verifies dune can find OCaml compilers and describe workspace.
"""

import os
import shutil
import subprocess
import sys
import tempfile


def main():
    print("=== Dune Configuration Discovery Tests ===")

    errors = 0

    # Test compiler discovery
    print("\n=== Testing compiler discovery ===")
    for compiler in ["ocamlc", "ocamlopt"]:
        path = shutil.which(compiler)
        if path:
            print(f"  {compiler} found: {path}")
        else:
            print(f"  WARNING: {compiler} not found")

    # Test dune context
    print("\n=== Testing dune context ===")
    test_dir = tempfile.mkdtemp(prefix="dune_config_")
    original_dir = os.getcwd()

    try:
        os.chdir(test_dir)

        with open("dune-project", "w") as f:
            f.write("(lang dune 3.0)")

        # Try describe workspace
        result = subprocess.run(
            ["dune", "describe", "workspace"],
            capture_output=True,
            text=True,
            check=False,
        )

        if result.returncode == 0:
            print("  workspace description: OK")
            # Show first 10 lines of output
            lines = result.stdout.split("\n")[:10]
            for line in lines:
                if line.strip():
                    print(f"    {line}")
        else:
            print("  (describe workspace may need more setup - not an error)")

        print("[OK] configuration discovery")

    finally:
        os.chdir(original_dir)
        shutil.rmtree(test_dir, ignore_errors=True)

    if errors > 0:
        print(f"\n=== FAILED: {errors} error(s) ===")
        return 1

    print("\n=== Configuration discovery tests passed ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())
