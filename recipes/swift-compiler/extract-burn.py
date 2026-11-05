"""Extract named MSI packages and their cabinets from a WiX Burn bundle.

Usage: extract-burn.py BUNDLE.exe OUTPUT_DIR PACKAGE.msi [PACKAGE.msi ...]

Burn appends two cabinets to the executable: the UX cabinet, whose file "0"
is the BurnManifest.xml, and the attached payload cabinet, whose files are
named by opaque source paths (a0, a1, ...). The manifest maps each MSI package
to its payloads, so the indices need not be hardcoded per release.
"""

from __future__ import annotations

import mmap
import shutil
import struct
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

CHUNK = 16 * 1024 * 1024


def find_cabinets(data: mmap.mmap, file_size: int) -> list[tuple[int, int]]:
    """Return (offset, size) of every plausible embedded cabinet."""
    cabinets = []
    offset = 0
    while (offset := data.find(b"MSCF", offset)) != -1:
        if offset + 12 <= file_size:
            size = struct.unpack_from("<I", data, offset + 8)[0]
            if size > 0 and offset + size <= file_size:
                cabinets.append((offset, size))
        offset += 4
    return cabinets


def copy_range(data: mmap.mmap, offset: int, size: int, destination: Path) -> None:
    with destination.open("wb") as output:
        for position in range(offset, offset + size, CHUNK):
            output.write(data[position : min(position + CHUNK, offset + size)])


def extract(cabinet: Path, output: Path, names: list[str]) -> None:
    subprocess.run(
        ["7z", "x", "-y", f"-o{output}", str(cabinet), *names],
        check=True,
        stdout=subprocess.DEVNULL,
    )


def main() -> None:
    bundle = Path(sys.argv[1])
    output = Path(sys.argv[2])
    packages = sys.argv[3:]
    output.mkdir(parents=True, exist_ok=True)
    file_size = bundle.stat().st_size

    with tempfile.TemporaryDirectory(dir=output) as scratch_dir:
        scratch = Path(scratch_dir)
        with bundle.open("rb") as stream, mmap.mmap(
            stream.fileno(), 0, access=mmap.ACCESS_READ
        ) as data:
            cabinets = find_cabinets(data, file_size)
            if len(cabinets) < 2:
                raise RuntimeError(f"no Burn cabinets found in {bundle}")
            # The UX cabinet comes first; the attached container is the largest.
            copy_range(data, *cabinets[0], scratch / "ux.cab")
            copy_range(data, *max(cabinets, key=lambda c: c[1]), scratch / "attached.cab")

        extract(scratch / "ux.cab", scratch / "ux", ["0"])
        manifest = ET.parse(scratch / "ux" / "0").getroot()
        namespace = manifest.tag.partition("}")[0] + "}"
        payloads = {
            payload.get("Id"): payload
            for payload in manifest.iter(f"{namespace}Payload")
            if payload.get("Container") == "WixAttachedContainer"
        }
        msis = {
            msi.get("Id"): msi for msi in manifest.iter(f"{namespace}MsiPackage")
        }

        wanted = []
        for package in packages:
            if package not in msis:
                raise RuntimeError(f"{package} not in bundle; found {sorted(msis)}")
            for ref in msis[package].iter(f"{namespace}PayloadRef"):
                wanted.append(payloads[ref.get("Id")])

        extract(
            scratch / "attached.cab",
            scratch / "payloads",
            [payload.get("SourcePath") for payload in wanted],
        )
        for payload in wanted:
            source = scratch / "payloads" / payload.get("SourcePath")
            shutil.move(source, output / payload.get("FilePath"))
            print(f"{payload.get('SourcePath')} -> {payload.get('FilePath')}")


if __name__ == "__main__":
    main()
