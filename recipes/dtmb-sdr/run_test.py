"""Conda recipe smoke tests for dtmb-sdr.

Exercises the console entry points, verifies the packaged native
executables and LDPC data files, and runs a real pipe round-trip through
one native stage.
"""

from __future__ import annotations

import os
from pathlib import Path
import subprocess
import sys

import dtmb


def run(command: list[str], **kwargs) -> subprocess.CompletedProcess:
    result = subprocess.run(command, capture_output=True, **kwargs)
    if result.returncode != 0:
        raise SystemExit(
            f"command failed ({result.returncode}): {command}\n"
            f"stdout: {result.stdout[:2000]}\nstderr: {result.stderr[:2000]}"
        )
    return result


def main() -> None:
    package_dir = Path(dtmb.__file__).resolve().parent
    bin_dir = package_dir / "bin"
    suffix = ".exe" if os.name == "nt" else ""

    executables = [
        "dtmb_core_ci8_resample",
        "dtmb_core_c3780_extract",
        "dtmb_core_deinterleave_qam64",
        "dtmb_core_deinterleave_qam",
        "dtmb_core_qam_softdemap",
        "dtmb_core_ldpc_bch_decode",
        "dtmb_core_pipe_buffer",
    ]
    missing = [name for name in executables if not (bin_dir / f"{name}{suffix}").is_file()]
    if missing:
        raise SystemExit(f"missing native executables: {missing}")

    for rate in (1, 2, 3):
        alist = package_dir / "data" / f"dtmb_ldpc_rate{rate}.alist"
        if not alist.is_file() or alist.stat().st_size == 0:
            raise SystemExit(f"missing or empty LDPC data file: {alist}")

    run(["dtmb-decode", "--help"])
    run(["dtmb-ts-analyze", "--help"])
    run([str(bin_dir / f"dtmb_core_ci8_resample{suffix}"), "--help"])

    payload = bytes(range(256)) * 4096
    result = run(
        [
            str(bin_dir / f"dtmb_core_pipe_buffer{suffix}"),
            "--buffer-bytes", "4194304",
            "--chunk-bytes", "65536",
            "--diagnostics-out", os.devnull,
            "-", "-",
        ],
        input=payload,
    )
    if result.stdout != payload:
        raise SystemExit(
            f"pipe_buffer round-trip mismatch: wrote {len(result.stdout)} of {len(payload)} bytes"
        )

    print("dtmb-sdr conda smoke tests passed")


if __name__ == "__main__":
    main()
