# `conda-pypi` Repodata Patching (Removals)

This feedstock ships a declarative list of packages to remove from the
`conda-pypi` channel index, plus a small loader/validator library. In the
future, this feedstock will also be able to make other types of repodata
patches besides removals.

repo-core imports the loader, resolves each block `name` against its shard
index to artifact filenames, and makes the channel updates.

## What this feedstock ships

- `conda_pypi_repodata_patches/blocks/*.yaml`: one file per blocked
  package.
- `conda_pypi_repodata_patches.loader`: a loader/validator that parses
  the block files and exposes:

  ```python
  load_blocks() -> list[Block]   # each Block has .name .reason .details .issue
  blocked_names() -> set[str]    # convenience: {b.name for b in load_blocks()}
  ```

  `load_blocks()` validates schema at load time and raises `ValueError`
  (naming the offending file) on any invalid block.

## When to block a package

Three reasons are supported (validated by the loader):

- `mis-tagged-pure-python`: the PyPI wheel is tagged `py3-none-any`
  but contains native code, so it cannot live in the noarch channel.
- `name-conflict`: the PyPI package name shadows an existing
  conda-forge package.
- `maintainer-prefers-feedstock`: the conda-forge maintainer actively
  maintains the feedstock and prefers users install from conda-forge
  rather than the converted wheel. Include an `issue` link to the
  feedstock or discussion where possible.

## How to submit a block

1. Add `conda_pypi_repodata_patches/blocks/<name>.yaml`:

   ```yaml
   name: <exact conda package name>
   reason: mis-tagged-pure-python   # or: name-conflict, maintainer-prefers-feedstock
   details: |                        # optional, free-text evidence
     Why this package should be blocked.
   issue: <optional URL>             # optional tracking link
   ```

   `name` must be the exact package name (no globs). repo-core does an
   exact-name lookup against shard records.

2. Preview what your block would remove (see "Previewing removals" below)
   and validate locally:

   ```sh
   python -c "from conda_pypi_repodata_patches.loader import load_blocks; load_blocks()"
   ```

   The build test in `recipe.yaml` also asserts the loader returns exactly
   the seeded block set.

3. Open a PR describing why the package should be blocked, with evidence.
   Paste the contents of `show_diff_result.txt` into the PR description.

## Previewing removals

`show_diff.py` (dev-only, not shipped) shows exactly what the current blocks
would remove from the channel: a per-name summary plus a unified diff of the
affected shard records. It needs `msgpack`, and `backports.zstd` on Python
< 3.14 (3.14+ uses the stdlib `compression.zstd` module):

```sh
conda create -n show-diff msgpack backports.zstd
```

1. From this recipe directory (so the package is importable), run:

   ```sh
   python show_diff.py
   ```

   This writes `show_diff_result.txt` in the current directory and prints the
   same text to stdout. A blocked name that is already absent from the shard
   index is reported as `no-op`.

2. To avoid re-downloading the ~25 MB shard index on every run, use:

   ```sh
   python show_diff.py --use-cache
   ```

   Downloads are always written to `cache/` (override with the `CACHE_DIR`
   environment variable); `--use-cache` reads from it without touching the
   network. `--channel` and `--subdir` are also available but default to the
   `conda-pypi` channel's `noarch` subdir.

3. Paste `show_diff_result.txt` into your PR description.

## License

BSD-3-Clause.
