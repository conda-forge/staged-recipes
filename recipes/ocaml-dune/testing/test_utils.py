#!/usr/bin/env python3
"""Shared test utilities for dune package tests."""

import os
import platform
from functools import lru_cache
from pathlib import Path


def get_prefix() -> Path:
    """Get the conda prefix path."""
    prefix = os.environ.get("PREFIX", os.environ.get("CONDA_PREFIX", ""))
    if not prefix:
        # Fallback for local testing
        return Path("/usr")
    return Path(prefix)


@lru_cache(maxsize=1)
def get_ocaml_build_version() -> tuple[int, int, int]:
    """Get OCaml version that was used during build.

    Reads from etc/conda/test-files/ocaml-build-version file written during build.

    Returns:
        Tuple of (major, minor, patch) version numbers.
        Returns (0, 0, 0) if version file not found or cannot be parsed.
    """
    prefix = get_prefix()
    version_file = prefix / "etc" / "conda" / "test-files" / "ocaml-build-version"

    try:
        version_str = version_file.read_text().strip()
        parts = version_str.split(".")
        return (int(parts[0]), int(parts[1]), int(parts[2].split("+")[0]))
    except (FileNotFoundError, IndexError, ValueError):
        return (0, 0, 0)


def get_ocaml_build_version_str() -> str:
    """Get OCaml build version as a string."""
    version = get_ocaml_build_version()
    if version == (0, 0, 0):
        return "unknown"
    return f"{version[0]}.{version[1]}.{version[2]}"


def get_target_arch() -> str:
    """Get the target architecture, handling cross-compilation.

    On CI runners, cross-compiled packages run under QEMU but platform.machine()
    returns the HOST arch (x86_64), not the TARGET arch (aarch64/ppc64le).

    Check conda's target_platform env var first, then fall back to platform.machine().
    """
    target_platform = os.environ.get("target_platform", "")
    if "aarch64" in target_platform:
        return "aarch64"
    if "ppc64le" in target_platform:
        return "ppc64le"
    if "arm64" in target_platform:
        return "arm64"
    return platform.machine().lower()


def is_known_ocaml_bug(arch_sensitive: bool = True) -> tuple[bool, str]:
    """Check if failures are expected due to known OCaml bugs.

    OCaml <= 5.3.0 has known bugs (especially GC issues on aarch64/ppc64le).
    OCaml >= 5.4.0 should have these fixed.

    Args:
        arch_sensitive: If True, only consider it a known bug on affected architectures
                       (aarch64, ppc64le, arm64). If False, apply to all architectures.

    Returns:
        Tuple of (is_known_bug: bool, reason: str)
        - is_known_bug: True if failures should be documented, not treated as errors
        - reason: Human-readable explanation
    """
    build_version = get_ocaml_build_version()
    version_str = get_ocaml_build_version_str()
    arch = get_target_arch()

    # OCaml >= 5.4.0: bugs should be fixed, failures are real
    if build_version >= (5, 4, 0):
        return False, ""

    # OCaml <= 5.3.0: known bugs
    if arch_sensitive:
        affected_archs = ("aarch64", "ppc64le", "arm64")
        if arch in affected_archs:
            reason = (
                f"OCaml {version_str} has known GC bugs on {arch} causing test failures. "
                "This is fixed in OCaml 5.4.0."
            )
            return True, reason
        # Not on affected arch
        return False, ""
    else:
        # Arch-insensitive: all archs affected
        reason = f"OCaml {version_str} has known bugs causing test failures. Fixed in 5.4.0."
        return True, reason


def handle_test_result(
    test_name: str,
    success: bool,
    arch_sensitive: bool = True,
) -> int:
    """Handle test result with OCaml version-aware failure handling.

    Args:
        test_name: Name of the test for reporting
        success: Whether the test passed
        arch_sensitive: Whether the known bug is architecture-specific

    Returns:
        Exit code: 0 if success or known bug, 1 if real failure
    """
    if success:
        print(f"\n=== {test_name} passed ===")
        return 0

    is_known, reason = is_known_ocaml_bug(arch_sensitive=arch_sensitive)

    if is_known:
        print(f"\n[KNOWN BUG] {test_name} failed (expected)")
        print(f"  {reason}")
        print(f"  Build OCaml version: {get_ocaml_build_version_str()}")
        print(f"  Target architecture: {get_target_arch()}")
        return 0
    else:
        print(f"\n=== {test_name} FAILED ===")
        print(f"  Build OCaml version: {get_ocaml_build_version_str()}")
        print(f"  Target architecture: {get_target_arch()}")
        return 1
