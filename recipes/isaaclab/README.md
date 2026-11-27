# Updating the `isaaclab` recipe (for agents and maintainers)

Maintainer aid that stays in the feedstock together with `pixi.toml`.
The skill `contributing-to-conda-forge` covers the general conda-forge flow.

## Update flow

1. Diff the upstream tag against the previous one (`pyproject.toml` of every `source/*` member, `tools/wheel_builder/gen_pyproject.py`) and audit the pins in `recipe.yaml` against it.
   The `run` lists are manual because conda names and pins differ from PyPI.
2. Bump `version` and `sha256`, reset `build_number` to 0.
3. Check that the recipe builds and passes its own tests (a local build covers one platform):
   ```bash
   rattler-build build --recipe recipes/isaaclab/recipe.yaml -m .ci_support/linux64.yaml --output-dir /tmp/rb-out
   ```
   Do not pass `-c` together with the variant file.
4. Run the local verification below.

## Local verification with pixi

`pixi.toml` has one environment: the package built from `recipe.yaml` through the pixi-build backend plus every closed-source wheel the tests can use (`omniverseclient`, `ovrtx`, `ovstage`, `ovphysx`), pytest and flaky.
The conda-forge CI has none of these wheels and no GPU, so this is the only place where the extended suite runs.

```bash
cd recipes/isaaclab
pixi run plain                     # Newton idle smoke (CPU, or GPU on the cuda platform)
pixi run ovrtx                     # RTX renderer smoke, cuda platform only
pixi run unit <IsaacLab source>    # the test script below
```

`<IsaacLab source>` is a tree of the packaged tag, for example from `GIT_LFS_SKIP_SMUDGE=1 git archive <tag> source | tar -x -C <dir>`.
LFS files are pointers there, and the script skips the tests that need them.
To run those too, check out the LFS files (today only `source/isaaclab_ov/test/assets/data/articulation_ordering_branching.usda`).

Keep `[constraints] cuda-version` in `pixi.toml` matching the driver (`nvidia-smi` prints the maximum CUDA), and clear `~/.cache/warp` after a driver or CUDA change.

## One test script

`run_unit_tests.sh` is shared by the recipe test (shipped with `files: recipe:`) and the local pixi task, so both run the same selection.
Its header explains what it detects (GPU, `omni.client`, `ovphysx`) and why the `isaaclab_ov` tests run in two processes on a GPU machine.
Edit the script only: the recipe calls `bash run_unit_tests.sh .`.
When bumping the version, re-check its list of tests skipped for missing LFS data.
