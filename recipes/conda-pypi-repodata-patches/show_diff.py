"""Preview what the blocks in this feedstock would remove from conda-pypi.

Run from the recipe directory (so ``conda_pypi_repodata_patches`` is
importable)::

    python show_diff.py               # fresh download of the shard index
    python show_diff.py --use-cache   # reuse cache/ from a previous run

Writes ``show_diff_result.txt`` in the current directory and prints the same
text to stdout; paste it into your PR description.

Dev-only dependencies: ``msgpack``, and ``backports.zstd`` on
Python < 3.14 (3.14+ uses stdlib ``compression.zstd``).
"""

from __future__ import annotations

import argparse
import difflib
import json
import os
import urllib.request
from pathlib import Path

import msgpack

try:
    from compression import zstd  # Python 3.14+ stdlib (PEP 784)
except ImportError:
    from backports import zstd

from conda_pypi_repodata_patches.loader import load_blocks

USER_AGENT = "conda-pypi-repodata-patches/show_diff"
DEFAULT_CHANNEL = "https://conda.anaconda.org/conda-pypi"
CACHE_DIR = Path(os.environ.get("CACHE_DIR", "cache"))


def fetch(url: str, cache_path: Path, use_cache: bool) -> bytes:
    if use_cache and cache_path.exists():
        return cache_path.read_bytes()
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request) as response:
        data = response.read()
    cache_path.parent.mkdir(parents=True, exist_ok=True)
    cache_path.write_bytes(data)
    return data


def unpack_zst_msgpack(data: bytes):
    return msgpack.unpackb(zstd.decompress(data), raw=False)


def normalize(value):
    if isinstance(value, bytes):
        return value.hex()
    if isinstance(value, dict):
        return {key: normalize(val) for key, val in value.items()}
    if isinstance(value, list):
        return [normalize(item) for item in value]
    return value


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--channel", default=DEFAULT_CHANNEL)
    parser.add_argument("--subdir", default="noarch")
    parser.add_argument(
        "--use-cache",
        action="store_true",
        help="Reuse (and populate) $CACHE_DIR instead of always downloading.",
    )
    args = parser.parse_args()

    base = f"{args.channel.rstrip('/')}/{args.subdir}"
    index = unpack_zst_msgpack(
        fetch(
            f"{base}/repodata_shards.msgpack.zst",
            CACHE_DIR / args.subdir / "repodata_shards.msgpack.zst",
            args.use_cache,
        )
    )
    shards = index["shards"]

    out: list[str] = []
    for block in load_blocks():
        out.append("=" * 80)
        out.append(f"{block.name} (reason: {block.reason})")
        shard_hash = shards.get(block.name)
        if shard_hash is None:
            out.append(f"no-op: {block.name} not in shard index")
            continue
        hex_hash = shard_hash.hex()
        shard = unpack_zst_msgpack(
            fetch(
                f"{base}/shards/{hex_hash}.msgpack.zst",
                CACHE_DIR / args.subdir / "shards" / f"{hex_hash}.msgpack.zst",
                args.use_cache,
            )
        )
        records = shard.get("v3", {}).get("whl", {})
        normalized = sorted(
            (normalize(record) for record in records.values()),
            key=lambda record: record["fn"],
        )
        fns = [record["fn"] for record in normalized]
        out.append(f"{len(fns)} artifacts would be removed: {', '.join(fns)}")
        out.append(f"shard index entry removed: {block.name} -> {hex_hash}")
        before = json.dumps(normalized, indent=2, sort_keys=True).splitlines()
        out.extend(
            difflib.unified_diff(
                before,
                [],
                fromfile=f"{args.subdir}/shards/{hex_hash}.msgpack.zst (current)",
                tofile=f"{args.subdir}/shards/{hex_hash}.msgpack.zst (blocked)",
                lineterm="",
            )
        )

    result = "\n".join(out) + "\n"
    Path("show_diff_result.txt").write_text(result, encoding="utf-8")
    print(result, end="")


if __name__ == "__main__":
    main()
