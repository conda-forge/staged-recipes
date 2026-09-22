# `isaaclab` recipe (review notes)

Notes for the staged-recipes review of [Isaac Lab](https://github.com/isaac-sim/IsaacLab).
This file and `pixi.toml` are maintainer aids and are removed before merge. Only
`recipe.yaml` and `gen_extra_metadata.py` ship in the feedstock.

## Package model

Upstream ships a single `isaaclab` wheel that bundles every `isaaclab*`
extension as a top-level module (`tools/wheel_builder`). The third-party pins are
centralized in the root `pyproject.toml` under `[project.dependencies]`, and each
`source/*/pyproject.toml` only declares interpackage deps.

The recipe mirrors that layout:

- The `isaaclab` output installs every workspace member under `source/` into one
  package. Its `run:` list is the third-party set from the root `pyproject.toml`.
- The subpackages are the pip *extras* that add third-party deps on top of the
  base: `isaaclab-video`, `isaaclab-sb3`, `isaaclab-viser`, `isaaclab-rerun`,
  `isaaclab-mimic`, `isaaclab-tetrahedralization`, `isaaclab-leapp`,
  `isaaclab-torchrl`. `isaaclab-all` aggregates the ones whose deps resolve on
  conda-forge.
- The `rsl-rl` extra is already in the base install, so it has no subpackage.

## Build and name mapping

The `build` script stays close to a plain install instead of running the
upstream wheel builder:

- It autodiscovers every workspace member (`source/isaaclab` and each
  `source/isaaclab_*`) and installs it with `pip install --no-deps
  --no-build-isolation`.
- It skips `isaaclab_teleop`: the optional XR teleoperation extension, off the
  core import path, whose OpenXR runtime (`isaacteleop`) is not on conda-forge.
  `isaaclab_ov` is shipped even though its `ovphysx`/`ovrtx` backends are not on
  conda-forge, because the base imports it unconditionally
  (`isaaclab/app/sim_launcher.py`) and its config classes import fine without
  them.
- After the installs it copies `apps/` and `tools/template` into the installed
  core package (`$SP_DIR/isaaclab/`), the same resources the upstream wheel
  builder co-locates there.

No path patch is needed. [isaac-sim/IsaacLab#7438](https://github.com/isaac-sim/IsaacLab/pull/7438)
flattens the core package and resolves its runtime resources through
`isaaclab/_paths.py::ISAACLAB_ROOT`, computed relative to the install directory,
so the `isaaclab` CLI works from the flat package. #7438 is already in
`release/3.0.0`, which the recipe tracks.

A few PyPI names do not match their conda-forge package, so the `run:` lists
remap them by hand:

| PyPI name | conda-forge package |
|---|---|
| `pin` | `pinocchio` |
| `pin-pink` | `pink` |
| `newton[sim]` | `newton-sim` |
| `matplotlib` | `matplotlib-base` |
| `lazy_loader` | `lazy-loader` |
| `torch` | `pytorch` |
| `torchrl` | `pytorchrl` |

## Source revision

`source` is pinned to a `release/3.0.0` SHA (`76c7c60`, commit date
`2026-09-21`) for a reproducible build, rather than tracking the moving branch.
`release/3.0.0` already carries the flattened wheel layout (#7438 merged), so no
fork or patch is needed. The version is a dev marker `3.0.0.devYYYYMMDD` (the
commit date of the pinned `rev`), which sorts below the eventual `3.0.0` GA.
Switch to the commented `url` + `sha256` block and a plain `3.0.0` once upstream
tags v3.

## Patches

Two small patches gate `unit` tests that need the source checkout rather than an
installed package. Upstream [isaac-sim/IsaacLab#7389](https://github.com/isaac-sim/IsaacLab/pull/7389)
added the `source_checkout_root` fixture that auto-skips such tests, but a few
CLI tests predate it. Both patches wire those tests onto the same fixture:

- `0001-skip-checkout-only-launcher-tests.patch`: the five `test_launcher_*` in
  `cli/test_env_commands.py`, resolving the launcher from the checkout root.
- `0002-skip-checkout-only-cli-install-tests.patch`: `TestCommandInstallDispatch`,
  `TestEnsureCudaTorch`, one `TestEnsureNewton` case, the two
  `TestInstallRootExtraExcludesIsaacSim` cases, and
  `test_teleop_workflow_help_exposes_task_preset_selectors`.

Both use the fixture-provided path where the tests access checkout files and are
upstreamable as-is.

## What is not packaged

Some deps cannot be mirrored on conda-forge. The two required ones
(`omniverseclient`, `isaacsim-asset-isolated`) are why the base `isaaclab` does
not resolve end-to-end on conda-forge yet. The others only gate their extra, and
their subpackages stay commented in `recipe.yaml`.

| package | reason | required / extra |
|---|---|---|
| `omniverseclient` | closed-source, not redistributable | required |
| `isaacsim-asset-isolated` | closed-source, not redistributable | required |
| `isaacsim` | closed-source, not redistributable | `extra=isaacsim`, `extra=teleop` |
| `isaacteleop` | closed-source, not redistributable | `extra=teleop` |
| `ovphysx`, `ovrtx`, `ovstage` | closed-source, not redistributable | `extra=ov` |
| `skrl` | no conda-forge feedstock | `extra=skrl` |
| `rl-games`, `standard-distutils` | no conda-forge feedstock | `extra=rl-games` |
| `rlinf` stack | deps exist but do not co-solve | `extra=rlinf` |

The disabled extra subpackages are `isaaclab-skrl`, `isaaclab-rl-games` and
`isaaclab-rlinf`. `rlinf` is blocked by a solver conflict, not a missing
feedstock: `decord2` pulls `ffmpeg 9 -> libopenvino-onnx-frontend -> libabseil
20260526`, while `ray-default` pins `libgrpc` to an older `libabseil`, so the two
cannot share it until the conda-forge `libabseil` migration settles.

## Pin changes vs upstream

The recipe tracks the `release/3.0.0` pins 1:1. Upstream states its third-party
versions as exact `==X.Y.Z`; the recipe mirrors each as the conda-forge idiom
`X.Y.Z.*` (e.g. `torchvision==0.27.0 -> torchvision 0.27.0.*`), which resolves to
the same release but tolerates the conda build string.

A few pins cannot track upstream verbatim. Re-check these whenever the `rev`
bumps.

| conda-forge package | upstream pin | recipe pin | reason |
|---|---|---|---|
| `pytorch` | `==2.12.0` | `>=2.11.0,<2.12` | downgrade a minor so the whole stack co-solves with the `torchrl` extra. `pytorchrl` needs `libtorch`, and the only `2.12` build (`libtorch 2.12.1`) requires a newer `libabseil` than `mujoco 3.12` (pulled by `newton-sim`) allows. `torch 2.11` is the highest that resolves everything, and it drags `torchvision` to `0.26.0` |
| `torchvision` | `==0.27.0` | `0.26.0.*` | pinned by the `torch 2.11` downgrade above (`0.27` needs `torch 2.12`) |
| `transformers` | `==5.10.4` | `>=5.10.4` | conda-forge has no `5.10.4` build (nearest `5.16.1`); floor instead of exact |
| `pytetwild` (`pytetwild[all]`) | `>=0.3.0,<0.4` | `>=0.3.0` (+ `pyvista`) | relax the `<0.4` cap: conda-forge only ships `0.4.2`, and the `tetrahedralize` API is unchanged across `0.3`/`0.4`. `pyvista` is the sole `[all]` member |
| `newton-usd-schemas` | `>=0.2.0` declared, `>=0.4.1` via `[tool.uv]` | `>=0.4.1` | match the effective upstream floor from the `override-dependencies` block |

`onnxscript>=0.5` is a recipe-only base dep kept to avoid a regression.
`gitpython>=3.1.59` and `Jinja2` (`-> jinja2`) are new base deps in
`release/3.0.0`, mirrored 1:1.

## Worth upstreaming

Local deviations that would help everyone if they landed upstream. Resolved rows
are kept at the bottom for context.

| Priority | Topic | Note |
|---|---|---|
| High | Closed-source Omniverse wheels | The base needs `omniverseclient` and `isaacsim-asset-isolated` (closed-source), so nothing resolves end-to-end. Making the Omniverse backends optional would make Isaac Lab packageable. |
| Medium | Wheel build layout | `tools/wheel_builder/stage.py` flattens extensions by copying each inner package to top-level, duplicating `config`/`data` and rewriting a hardcoded `os.path.dirname(__file__), "../"` to `""`. Resolving resources via `importlib.resources` would drop that. |
| Medium | Exact patch pins | Upstream pins core deps to the exact patch (`torch==2.12.0`, `torchvision==0.27.0`, `torchaudio==2.11.0`, plus `transformers`, `warp-lang`, `pin-pink`, `daqp`, `usd-exchange`, `rsl-rl-lib`, `newton[sim]`). A patch-level `==` is very problematic downstream: it makes conda-forge shadow every patch and blocks co-install with any package that pins a different one. Concretely, `torch==2.12.0` is unsatisfiable together with the `torchrl` extra: the only conda `pytorchrl` build for `2.12` pulls `libtorch 2.12.1`, whose `libabseil` conflicts with the `mujoco 3.12` that `newton-sim` requires, so the recipe has to downgrade the whole stack to `torch 2.11`. The upstream pin set is itself inconsistent (`torch 2.12` with `torchaudio 2.11`). Declared specs should be `>=` on the lowest working version, keeping the exact reproducible pins in `uv.lock` for developers. Users who want the exact validated set could opt into it through a dedicated extra (e.g. `isaaclab[pinned]`) instead of forcing the patch pins on every consumer. Raised in [#5084](https://github.com/isaac-sim/IsaacLab/issues/5084#issuecomment-4138346195). |
| Low | Missing feedstocks | `skrl` and `rl-games` (plus `standard-distutils`) have no conda-forge feedstock, so their extras cannot be packaged. |
| Low | `albumentations` archived | The `rlinf` extra depends on the archived `albumentations`, superseded by [`albumentationsx`](https://github.com/conda-forge/staged-recipes/pull/34440). |
| Low | Pre-fixture CLI tests | A few CLI `unit` tests predate the `source_checkout_root` fixture ([#7389](https://github.com/isaac-sim/IsaacLab/pull/7389)) and still need the checkout. The recipe gates them via patches 0001/0002; the one-line changes are upstreamable. |
| Resolved | Flat wheel layout | [#7438](https://github.com/isaac-sim/IsaacLab/pull/7438) makes the core a flat package resolving resources via `_paths.py::ISAACLAB_ROOT`, so the recipe drops the old path patch. |
| Resolved | Device-hardcoded tests | [#7918](https://github.com/isaac-sim/IsaacLab/pull/7918) (backported via [#7921](https://github.com/isaac-sim/IsaacLab/pull/7921)) adds `test_devices()` so the `cuda` cases self-skip on CPU, dropping the old device patch. |
| Resolved | `newton[sim]` declared spec | Upstream now declares `newton[sim]==1.6.0` directly instead of a loose `>=1.2.0` masked by a `uv` override. |

## Dependency drift detection (`pip check`)

The recipe validates its `run:` lists against upstream at build time, so an
upstream dependency change turns CI red instead of shipping stale metadata:

- **Base.** The per-member `pip install --no-deps` drops the third-party deps, so
  the build regenerates them with upstream's `tools/wheel_builder/gen_pyproject.py`
  and `gen_extra_metadata.py base` reinjects them as `Requires-Dist` into the
  installed `isaaclab.dist-info`. The base `pip_check` then fails if a declared
  base dep is missing.
- **Extras.** `pip check` ignores `; extra == "..."` markers, so each metapackage
  build runs `gen_extra_metadata.py extra` to emit a synthetic
  `isaaclab_extra_<name>.dist-info` whose `Requires-Dist` is that extra's set. Its
  `pip_check: true` test fails if the recipe's `run:` list drifts from upstream.

Both layers are name-only (version specifiers dropped): conda-forge often serves
newer builds than upstream's exact pins, so a name check catches added or removed
deps without fighting the pin policy.

## Validation

A render-only pass checks that the recipe parses and the outputs resolve:

```bash
pixi exec --spec rattler-build -- \
  rattler-build build --recipe recipe.yaml --target-platform linux-64 --render-only
```

`pixi.toml` in this directory is a self-contained local build plus smoke test.
It builds `isaaclab-all` from `recipe.yaml` as a source dependency, so pixi
materializes the artifact itself with no local channel to seed first:

```bash
pixi run plain            # build, resolve the CUDA 13 stack and run a Newton idle smoke
pixi run -e ovrtx ovrtx   # same, plus the PyPI-only Omniverse RTX backends
```

Both tasks pull one closed-source wheel (`omniverseclient`) from
`pypi.nvidia.com`, the packaging blocker above. A `glibc 2.35` custom platform is
set so the `manylinux_2_35` wheels resolve, and the platform pins `cuda 13`.

The base `isaaclab` output runs the upstream `unit` suite against the installed
package (`tests` in `recipe.yaml`). It collects only `unit`-marked files (pointing
pytest at `test/` would import standalone scripts that parse args at import) and
adapts to the runner, running the `cuda` cases only when a GPU is visible. Only
the `unit` suite is reachable downstream: the sim/integration tests need a running
CUDA driver, which the CPU runners do not provide.

On staged-recipes CI the `linux_64` (CPU) build passes on the CPU-only subset.
The `linux_64_cuda_*` variants fail earlier, at test-env setup, with `No space
left on device` while linking `libtorch_cuda.so` (the CUDA `libtorch` plus the
build artifacts exceed the runner disk). That is an infrastructure limit of the
shared runners, not the recipe: a runner with a GPU picks up the `cuda` cases.
