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

Two reasons are supported (validated by the loader):

- `mis-tagged-pure-python`: the PyPI wheel is tagged `py3-none-any`
  but contains native code, so it cannot live in the noarch channel.
- `name-conflict`: the PyPI package name shadows an existing
  conda-forge package.

## How to submit a block

1. Add `conda_pypi_repodata_patches/blocks/<name>.yaml`:

   ```yaml
   name: <exact conda package name>
   reason: mis-tagged-pure-python   # or: name-conflict
   details: |                        # optional, free-text evidence
     Why this package should be blocked.
   issue: <optional URL>             # optional tracking link
   ```

   `name` must be the exact package name (no globs). repo-core does an
   exact-name lookup against shard records.

2. Validate locally:

   ```sh
   python -c "from conda_pypi_repodata_patches.loader import load_blocks; load_blocks()"
   ```

   The build test in `recipe.yaml` also asserts the loader returns exactly
   the seeded block set.

3. Open a PR describing why the package should be blocked, with evidence.

## License

BSD-3-Clause.
