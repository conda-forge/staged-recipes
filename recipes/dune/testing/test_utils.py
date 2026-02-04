#!/usr/bin/env python3
"""Shared test utilities for dune package tests."""

import subprocess
from functools import lru_cache


@lru_cache(maxsize=1)
def get_ocaml_version() -> tuple[int, int, int]:
    """Get OCaml version as a tuple (major, minor, patch).

    Returns:
        Tuple of (major, minor, patch) version numbers.
        Returns (0, 0, 0) if OCaml is not found or version cannot be parsed.
    """
    try:
        result = subprocess.run(
            ["ocaml", "-version"],
            capture_output=True,
            text=True,
            check=False,
        )
        # Output: "The OCaml toplevel, version 5.3.0"
        version_str = result.stdout.strip().split()[-1]
        parts = version_str.split(".")
        return (int(parts[0]), int(parts[1]), int(parts[2].split("+")[0]))
    except (IndexError, ValueError, FileNotFoundError):
        return (0, 0, 0)


def requires_ocaml_version(max_version: tuple[int, int, int] | None = None,
                           min_version: tuple[int, int, int] | None = None) -> bool:
    """Check if current OCaml version meets requirements.

    Args:
        max_version: Maximum OCaml version (exclusive), e.g., (5, 4, 0) for < 5.4.0
        min_version: Minimum OCaml version (inclusive), e.g., (5, 0, 0) for >= 5.0.0

    Returns:
        True if requirements are met, False otherwise.
    """
    current = get_ocaml_version()
    if current == (0, 0, 0):
        return False

    if min_version and current < min_version:
        return False
    if max_version and current >= max_version:
        return False
    return True


def is_known_failure(max_version: tuple[int, int, int] | None = None,
                     min_version: tuple[int, int, int] | None = None) -> bool:
    """Check if current OCaml version is outside supported range (known failure).

    Use this to document expected failures rather than skipping tests.

    Args:
        max_version: Maximum supported OCaml version (exclusive)
        min_version: Minimum supported OCaml version (inclusive)

    Returns:
        True if failures are expected (version outside supported range).
    """
    return not requires_ocaml_version(max_version=max_version, min_version=min_version)


def document_failure(test_name: str, max_version: tuple[int, int, int] | None = None,
                     min_version: tuple[int, int, int] | None = None,
                     reason: str = "") -> None:
    """Print documentation for expected failure based on OCaml version.

    Args:
        test_name: Name of the test
        max_version: Maximum supported OCaml version (exclusive)
        min_version: Minimum supported OCaml version (inclusive)
        reason: Additional context for the limitation
    """
    current = get_ocaml_version()
    version_str = f"{current[0]}.{current[1]}.{current[2]}"

    constraints = []
    if min_version:
        constraints.append(f">= {min_version[0]}.{min_version[1]}.{min_version[2]}")
    if max_version:
        constraints.append(f"< {max_version[0]}.{max_version[1]}.{max_version[2]}")

    constraint_str = " and ".join(constraints) if constraints else "unknown"

    print(f"[KNOWN] {test_name}: OCaml {version_str} outside supported range ({constraint_str})")
    if reason:
        print(f"        Reason: {reason}")
