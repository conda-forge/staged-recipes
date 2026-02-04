#!/usr/bin/env python3
"""Test: dune binary architecture validation

Verifies dune binary is built for a recognized architecture.
Works cross-platform using Python's struct module for PE parsing on Windows.
"""

import platform
import shutil
import struct
import subprocess
import sys


def check_unix_arch(binary_path):
    """Check architecture using file command on Unix."""
    result = subprocess.run(
        ["file", binary_path],
        capture_output=True,
        text=True,
        check=False,
    )
    arch_info = result.stdout.lower()
    print(f"File info: {result.stdout.strip()}")

    known_archs = [
        ("aarch64", "aarch64 (ARM 64-bit)"),
        ("arm aarch64", "aarch64 (ARM 64-bit)"),
        ("arm64", "arm64 (macOS ARM)"),
        ("x86-64", "x86_64 (AMD 64-bit)"),
        ("x86_64", "x86_64 (AMD 64-bit)"),
        ("powerpc", "ppc64le (POWER 64-bit)"),
        ("ppc64", "ppc64le (POWER 64-bit)"),
    ]

    for pattern, name in known_archs:
        if pattern in arch_info:
            print(f"  Detected architecture: {name}")
            print("[OK] Architecture check passed")
            return True

    print("[FAIL] Unrecognized binary format")
    return False


def check_windows_arch(binary_path):
    """Check PE architecture on Windows using native Python."""
    try:
        with open(binary_path, "rb") as f:
            # Read DOS header
            dos_header = f.read(64)
            if dos_header[:2] != b"MZ":
                print("[FAIL] Not a valid DOS/PE file")
                return False

            # Get PE header offset from DOS header at 0x3C
            pe_offset = struct.unpack("<I", dos_header[0x3C:0x40])[0]

            # Read PE signature
            f.seek(pe_offset)
            pe_sig = f.read(4)
            if pe_sig != b"PE\x00\x00":
                print("[FAIL] Invalid PE signature")
                return False

            # Read machine type (2 bytes after PE signature)
            machine_type = struct.unpack("<H", f.read(2))[0]

            machine_names = {
                0x8664: "AMD64 (x86-64)",
                0x014C: "i386 (x86)",
                0xAA64: "ARM64",
            }

            if machine_type in machine_names:
                name = machine_names[machine_type]
                print(f"  Machine type: {name}")
                if machine_type == 0x014C:
                    print("[FAIL] Expected 64-bit, got 32-bit x86")
                    return False
                print("[OK] Architecture check passed")
                return True
            else:
                print(f"[FAIL] Unknown machine type: 0x{machine_type:04X}")
                return False

    except Exception as e:
        print(f"[FAIL] Failed to read PE header: {e}")
        return False


def main():
    print("=== Dune Binary Architecture Tests ===")

    # Find dune binary
    dune_path = shutil.which("dune")
    if not dune_path:
        print("[FAIL] dune not found in PATH")
        return 1

    # On Windows, add .exe suffix if needed
    if platform.system() == "Windows" and not dune_path.endswith(".exe"):
        dune_path += ".exe"

    print(f"Binary: {dune_path}")

    if platform.system() == "Windows":
        success = check_windows_arch(dune_path)
    else:
        success = check_unix_arch(dune_path)

    if success:
        print("\n=== Architecture tests passed ===")
        return 0
    else:
        print("\n=== Architecture tests FAILED ===")
        return 1


if __name__ == "__main__":
    sys.exit(main())
