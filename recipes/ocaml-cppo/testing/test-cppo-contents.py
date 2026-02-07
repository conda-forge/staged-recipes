#!/usr/bin/env python3
"""Test: cppo package contents validation (strict)

Validates package contents based on what was actually built.
Checks marker file to determine if cppo_ocamlbuild was included.
"""

import os
import sys
from pathlib import Path


def get_prefix() -> Path:
    """Get the conda prefix path."""
    prefix = os.environ.get("PREFIX", os.environ.get("CONDA_PREFIX", ""))
    if not prefix:
        print("[FAIL] PREFIX/CONDA_PREFIX not set")
        sys.exit(1)
    return Path(prefix)


def is_windows() -> bool:
    """Check if running on Windows."""
    return sys.platform == "win32"


def get_library_prefix(prefix: Path) -> Path:
    """Get library prefix (PREFIX/Library on Windows, PREFIX on Unix)."""
    if is_windows():
        return prefix / "Library"
    return prefix


def check_cppo_ocamlbuild_built(prefix: Path) -> bool:
    """Check if cppo_ocamlbuild was built (from marker file)."""
    marker_file = prefix / "etc" / "conda" / "test-files" / "cppo_ocamlbuild_built"
    if marker_file.exists():
        content = marker_file.read_text().strip()
        return content == "1"
    return False


def check_files_exist(files: list[Path], description: str) -> bool:
    """Check that all files exist."""
    all_exist = True
    for f in files:
        if f.exists():
            print(f"  [OK] {f}")
        else:
            print(f"  [FAIL] {f} - NOT FOUND")
            all_exist = False

    if all_exist:
        print(f"[OK] {description}")
    else:
        print(f"[FAIL] {description}")
    return all_exist


def check_glob_exists(pattern_base: Path, pattern: str, description: str) -> bool:
    """Check that at least one file matches the glob pattern."""
    matches = list(pattern_base.glob(pattern))
    if matches:
        print(f"  [OK] {pattern_base / pattern} ({len(matches)} files)")
        print(f"[OK] {description}")
        return True
    else:
        print(f"  [FAIL] {pattern_base / pattern} - NO MATCHES")
        print(f"[FAIL] {description}")
        return False


def main() -> int:
    print("=== cppo package contents validation (strict) ===")

    prefix = get_prefix()
    lib_prefix = get_library_prefix(prefix)
    cppo_ocamlbuild_built = check_cppo_ocamlbuild_built(prefix)

    print(f"PREFIX: {prefix}")
    print(f"Library prefix: {lib_prefix}")
    print(f"cppo_ocamlbuild built: {cppo_ocamlbuild_built}")
    print()

    all_ok = True

    # === Binary check ===
    print("--- Checking binaries ---")
    if is_windows():
        cppo_bin = prefix / "Library" / "bin" / "cppo.exe"
        if not cppo_bin.exists():
            cppo_bin = prefix / "Library" / "bin" / "cppo"
    else:
        cppo_bin = prefix / "bin" / "cppo"

    if cppo_bin.exists():
        print(f"  [OK] {cppo_bin}")
        print("[OK] cppo binary")
    else:
        print(f"  [FAIL] {cppo_bin} - NOT FOUND")
        print("[FAIL] cppo binary")
        all_ok = False
    print()

    # === Core cppo files (always required) ===
    print("--- Checking core cppo files ---")
    core_files = [
        lib_prefix / "doc" / "cppo" / "LICENSE.md",
        lib_prefix / "doc" / "cppo" / "README.md",
    ]
    all_ok &= check_files_exist(core_files, "cppo documentation")
    all_ok &= check_glob_exists(lib_prefix / "lib" / "ocaml" / "cppo", "*", "cppo library files")
    print()

    # === cppo_ocamlbuild files (conditional) ===
    if cppo_ocamlbuild_built:
        print("--- Checking cppo_ocamlbuild files (REQUIRED - was built) ---")
        ocamlbuild_files = [
            lib_prefix / "doc" / "cppo_ocamlbuild" / "LICENSE.md",
            lib_prefix / "doc" / "cppo_ocamlbuild" / "README.md",
        ]
        all_ok &= check_files_exist(ocamlbuild_files, "cppo_ocamlbuild documentation")
        all_ok &= check_glob_exists(
            lib_prefix / "lib" / "ocaml" / "cppo_ocamlbuild", "*",
            "cppo_ocamlbuild library files"
        )
    else:
        print("--- Checking cppo_ocamlbuild files (SHOULD NOT EXIST - was not built) ---")
        unexpected_files = [
            lib_prefix / "doc" / "cppo_ocamlbuild",
            lib_prefix / "lib" / "ocaml" / "cppo_ocamlbuild",
        ]
        for f in unexpected_files:
            if f.exists():
                print(f"  [FAIL] {f} - UNEXPECTEDLY EXISTS")
                all_ok = False
            else:
                print(f"  [OK] {f} - correctly absent")
        if all_ok:
            print("[OK] cppo_ocamlbuild correctly not installed")
    print()

    # === Test files marker ===
    print("--- Checking test marker files ---")
    marker = prefix / "etc" / "conda" / "test-files" / "cppo_ocamlbuild_built"
    if marker.exists():
        print(f"  [OK] {marker}")
        print("[OK] test marker file")
    else:
        print(f"  [FAIL] {marker} - NOT FOUND")
        print("[FAIL] test marker file")
        all_ok = False
    print()

    # === Summary ===
    if all_ok:
        print("=== All package contents validated successfully ===")
        return 0
    else:
        print("=== Package contents validation FAILED ===")
        return 1


if __name__ == "__main__":
    sys.exit(main())
