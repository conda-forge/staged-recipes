"""Extract the attached payload cabinet from a WiX Burn executable."""

from __future__ import annotations

import mmap
import struct
import sys
from pathlib import Path


source = Path(sys.argv[1])
destination = Path(sys.argv[2])
file_size = source.stat().st_size

# Burn appends its cabinets to the executable. The first is the small UX
# cabinet; the attached payload cabinet is by far the largest valid cabinet.
candidates: list[tuple[int, int]] = []
with source.open("rb") as stream, mmap.mmap(
    stream.fileno(), 0, access=mmap.ACCESS_READ
) as data:
    offset = 0
    while (offset := data.find(b"MSCF", offset)) != -1:
        if offset + 12 <= file_size:
            cabinet_size = struct.unpack_from("<I", data, offset + 8)[0]
            if cabinet_size > 0 and offset + cabinet_size <= file_size:
                candidates.append((cabinet_size, offset))
        offset += 4

    if not candidates:
        raise RuntimeError(f"no embedded cabinet found in {source}")

    cabinet_size, cabinet_offset = max(candidates)
    with destination.open("wb") as output:
        end = cabinet_offset + cabinet_size
        for position in range(cabinet_offset, end, 16 * 1024 * 1024):
            output.write(data[position : min(position + 16 * 1024 * 1024, end)])

print(
    f"extracted {cabinet_size} byte Burn payload cabinet "
    f"at offset {cabinet_offset}"
)
