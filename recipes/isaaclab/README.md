# `isaaclab` recipe (maintainer notes)

This directory packages [Isaac Lab](https://github.com/isaac-sim/IsaacLab) for conda-forge. Read this before touching `recipe.yaml`.

## Objective: run Isaac Lab standalone with two commands

The point of packaging Isaac Lab for conda-forge is a trivial, self-contained setup. Once `isaaclab` is a conda package, [pixi](https://pixi.sh) resolves the whole stack (Isaac Lab, the Newton physics backend, a CUDA 13 PyTorch, all system libraries) from conda-forge and runs an example out of the box, with no manual CUDA or Omniverse install. The `pixi.toml` in this directory is a working demonstration:

1. Install pixi: <https://pixi.sh/latest/#installation>.
2. `pixi run plain`.

Pixi builds the recipe, materializes the environment for the custom CUDA 13 platform and runs a Newton idle training on the cartpole. There is nothing else to configure. See [Local validation](#local-validation) for details and the `ovrtx` variant.

## Model: one bundled package plus extra-only subpackages

Upstream ships a single `isaaclab` wheel that bundles every `isaaclab*` extension as a top-level module (see `tools/wheel_builder` in the IsaacLab repo). The third-party pins are centralized in the root `pyproject.toml` under `[project.dependencies]`, and each `source/*/pyproject.toml` only declares interpackage deps.

The recipe mirrors that layout:

- The `isaaclab` output installs every workspace member under `source/` into one package. Its `run:` list is the third-party set from the root `pyproject.toml`.
- The only real subpackages are the pip *extras* that add third-party deps on top of the base install: `isaaclab-video`, `isaaclab-sb3`, `isaaclab-viser`, `isaaclab-rerun`, `isaaclab-mimic`. `isaaclab-all` aggregates them.
- The `rsl-rl` extra is already part of the base install, so it has no subpackage.

This is intentionally closer to what upstream does than the earlier per-extension split, which was more idiomatic for conda-forge but did not match the upstream packaging.

## Build and name mapping

The `build` script keeps things close to a plain install instead of running the upstream wheel builder:

- It autodiscovers every workspace member, that is `source/isaaclab` and each `source/isaaclab_*`, and installs it with `pip install --no-deps --no-build-isolation`.
- It skips the members listed in the `skip_extensions` context variable. Today only `isaaclab_teleop` is skipped: it is the optional XR teleoperation extension, off the core import path (only `isaaclab.devices.openxr` pulls it), and its OpenXR runtime (`isaacteleop`) is not on conda-forge. `isaaclab_ov` is shipped even though its `ovphysx`/`ovrtx` backends are not on conda-forge, because the base package imports it unconditionally (`isaaclab/app/sim_launcher.py`) and its config classes import fine without those backends.
- It vendors the `apps/` and `scripts/` directories under `$PREFIX/share/isaaclab/`.

The `scripts/` copy is not optional. The `isaaclab` CLI resolves `isaaclab train` and `isaaclab play` to files under `scripts/reinforcement_learning/`. Upstream computes that root as `Path(__file__).parents[4]`, which for a plain install lands on `$PREFIX/lib` and dumps unqualified `apps/` and `scripts/` dirs there. The recipe applies `patches/0001-conda-forge-path-adjustments.patch` to resolve both dirs from `$PREFIX/share/isaaclab` instead, so the prefix stays clean.

A few PyPI names do not match their conda-forge package, so the `run:` lists remap them by hand. The same mapping is encoded in `gen_recipe_deps.py`:

| PyPI name | conda-forge package |
|---|---|
| `pin` | `pinocchio` |
| `pin-pink` | `pink` |
| `newton[sim]` | `newton-sim` |
| `matplotlib` | `matplotlib-base` |
| `lazy_loader` | `lazy-loader` |
| `torch` | `pytorch` |

## Regenerating the dependency list

Do not scrape a build log. The pins come from the root `pyproject.toml` at a given revision, so re-derive them with the helper script, which reuses the same workspace-stripping and extra-expansion logic as upstream `tools/wheel_builder/gen_pyproject.py`. It prints the core run deps and every extra group as tables (use `--no-extras` for core only, or `--extra NAME` for a single group), mapping each PyPI name to its conda-forge package and flagging the ones that are missing.

Requires `pixi >= 0.76`.

```bash
# core run deps plus every extra group (default), with the PyPI -> conda-forge name mapping and missing-package flags
pixi run --script gen_recipe_deps.py -- --rev release/3.0.0

# core deps only
pixi run --script gen_recipe_deps.py -- --rev release/3.0.0 --no-extras

# only a given extra group (repeatable)
pixi run --script gen_recipe_deps.py -- --rev release/3.0.0 --extra sb3
```

`--rev` takes any git ref (branch, tag or SHA). The `--` separates pixi's own flags from the script arguments, so pixi does not try to parse `--rev` itself. Reconcile the output against the `run:` lists in `recipe.yaml` by hand: the script maps names and flags what is missing, but the version bounds and the relax decisions stay a manual call.

## Source revision

`source` tracks the `release/3.0.0` branch by SHA until upstream tags the v3 GA. When the tag lands, switch to the commented `url` + `sha256` block and drop the `git`/`rev` pair.

The package version is a dev marker, `3.0.0.devYYYYMMDD`, where the date is the commit date of the pinned `rev` (e.g. `2026-08-21` for the current SHA). It sorts below the eventual `3.0.0` GA. Bump the date whenever the `rev` moves, and switch to a plain `3.0.0` once upstream tags v3.0.0.

## What is not packaged

Some deps cannot be mirrored on conda-forge, either because they are closed-source and not redistributable, or because they are open source but have no feedstock yet. The two required ones (`omniverseclient`, `isaacsim-asset-isolated`) are why the base `isaaclab` does not resolve end-to-end on conda-forge yet; the others only gate their extra.

| package | reason | required / extra |
|---|---|---|
| `omniverseclient` | closed-source, not redistributable | required |
| `isaacsim-asset-isolated` | closed-source, not redistributable | required |
| `isaacsim` | closed-source, not redistributable | `extra=isaacsim`, `extra=teleop` |
| `isaacteleop` | closed-source, not redistributable | `extra=teleop` |
| `ovphysx` | closed-source, not redistributable | `extra=ov`, `extra=ovphysx` |
| `ovrtx` | closed-source, not redistributable | `extra=ov`, `extra=ovrtx` |
| `ovstage` | closed-source, not redistributable | `extra=ov`, `extra=ovphysx`, `extra=ovrtx` |
| `pytetwild` | no conda-forge feedstock | `extra=tetrahedralization` |
| `skrl` | no conda-forge feedstock | `extra=skrl` |
| `rl-games` | no conda-forge feedstock | `extra=rl-games` |
| `standard-distutils` | no conda-forge feedstock | `extra=rl-games` |
| `leapp` | no conda-forge feedstock | `extra=leapp` |

The closed-source deps are dropped, the OSS-without-feedstock ones are kept commented in `recipe.yaml` so they can be re-enabled once a feedstock exists. The extra subpackages disabled as a consequence: `isaaclab-tetrahedralization`, `isaaclab-skrl`, `isaaclab-rl-games`, `isaaclab-rlinf`, plus the omitted `isaacsim`/`teleop`. Everything else builds: `isaaclab`, `isaaclab-all`, `isaaclab-video`, `isaaclab-sb3`, `isaaclab-viser`, `isaaclab-rerun`, `isaaclab-mimic`.

## Pin changes vs upstream

Upstream uses several exact pins that conda-forge cannot always match, plus two deps it pulls from a git rev via `uv` (which conda-forge cannot reproduce, so the recipe pins the matching released version). Here is what the recipe changes, and why. Re-check these whenever `--rev` bumps.

| conda-forge package | upstream pin | recipe pin | reason |
|---|---|---|---|
| `transformers` | `==4.57.6` | `4.57.6.*` | relax exact to the patch range |
| `warp-lang` | `==1.16.0` | `>=1.16.0` | relax |
| `pink` (PyPI `pin-pink`) | `==3.3.0` | `3.3.0.*` | relax |
| `daqp` | `==0.8.5` | `0.8.5.*` | relax |
| `usd-exchange` | `==2.3.0` | `>=2.3.0` | relax |
| `rsl-rl-lib` | `==5.4.1` | `5.4.1.*` | relax |
| `pyarrow` | transitive via `rerun-sdk` | `22.0.*` | match `rerun-sdk`'s Arrow stack |
| `newton-sim` (PyPI `newton[sim]`) | git rev `release-1.5` (`uv` override), spec `>=1.2.0` | `>=1.5.0` | match the `release-1.5` line upstream actually needs (their spec bump is pending) |
| `newton-usd-schemas` | `>=0.4.1` (`uv` override) | `>=0.4.1` | match the upstream `uv` override |

## Worth upstreaming

Some of the changes here are conda-forge specific and stay local, but a few are plain fixes or would help everyone if they landed upstream. Raise these with the Isaac Lab developers rather than carrying them here forever.

| Priority | Topic | What and why |
|---|---|---|
| High | Nested source tree kept in the wheel | The wheel builder ships `tools/wheel_builder/res/__init__.py` as the top-level `isaaclab/__init__.py`, and at [line 15](https://github.com/isaac-sim/IsaacLab/blob/e13060d3ab01a7d43a9863c6c9b7d3d565094c47/tools/wheel_builder/res/__init__.py#L15) it does `__path__.append(".../source/isaaclab/isaaclab")`, so the installed package is not a plain package but a shell that re-exposes a nested `source/isaaclab/isaaclab` tree through `__path__`. This is fragile (tooling that walks `__path__`, editable installs, name resolution) and is a likely source of future breakage. The default packaged layout should be a normal flat package that works out of the box when Isaac Sim is not installed, and only when Isaac Sim is present should the install do the extra path juggling its runtime needs. Right now it is the opposite: the path hacks run unconditionally and the plain case pays for them. |
| High | Closed-source Omniverse/Isaac Sim wheels | As long as the base install requires `omniverseclient` and `isaacsim-asset-isolated` (both closed-source, not on conda-forge), no conda-forge package can resolve end-to-end. A path that makes the Omniverse backends optional (idle sim without them) would make Isaac Lab packageable for real. |
| Medium | Wheel build layout | To flatten every `isaaclab_*` extension into one wheel, `tools/wheel_builder/build.sh` copies each inner package to top-level, duplicates `config/`/`data/` into it, `sed`-patches the `EXT_DIR = ...os.path.join(os.path.dirname(__file__), "../")` line (e.g. in `isaaclab_assets`) from `../` to `""`, then deletes the inner copy and `data/` while keeping `config/extension.toml` for Kit discovery. It hardcodes the `../` string and the `config`/`data` names and duplicates data. Resolving resources via `importlib.resources` would remove the per-package copy-and-`sed`. |
| Medium | `newton[sim]` declared spec | Upstream declares `newton>=1.2.0` but overrides it to the `release-1.5` git line via `uv`, so the real floor is 1.5. Bumping the declared spec to `>=1.5.0` drops the `uv` override and lets plain resolvers (conda-forge included) pick the right version. |
| Medium | Exact `==` pins | `transformers`, `warp-lang`, `pin-pink`, `daqp`, `usd-exchange`, `rsl-rl-lib` are pinned exact in `pyproject.toml` with no technical need. Exact pins force conda-forge to shadow every patch release and make co-install hard. The declared specs should be `>=` on the lowest version with a sufficient API, and the exact reproducible versions should stay in the upstream `uv.lock`, which is the right place for hard pinning. Already raised upstream in [isaac-sim/IsaacLab#5084](https://github.com/isaac-sim/IsaacLab/issues/5084#issuecomment-4138346195). |
| Low | Missing feedstocks | `pytetwild`, `skrl`, `rl-games` are open source but have no conda-forge feedstock, so their extras cannot be packaged. Upstream nudging them toward a feedstock would unblock those extras. |
| Low | `albumentations` is archived | The `rlinf` extra depends on `albumentations`, whose repository is archived and no longer maintained. It has been superseded by [`albumentationsx`](https://github.com/albumentations-team/AlbumentationsX). Moving the extra to `albumentationsx` tracks a maintained package (its conda-forge recipe is in [conda-forge/staged-recipes#34440](https://github.com/conda-forge/staged-recipes/pull/34440)). |
| Low | Unit tests not runnable against an installed package | Several `unit`-marked tests do not run against the installed, CPU-only, kitless package. Some hardcode `device="cuda:0"` instead of parametrizing over the available device (e.g. `deps/test_torch.py`, one case in `utils/warp/test_proxy_array.py`), so they fail where no GPU is present. Others read the source checkout instead of the package (root `pyproject.toml`, `uv.lock`, `tools/`, `apps/`, `scripts/`), e.g. `cli/test_install*`, `cli/test_uv_run_pyproject`, `cli/test_wheel_builder_metadata`, `cli/test_source_package_metadata`, `app/test_experience_files`, `test_scripts_warp_backward_ordering`. Making the `unit` suite device-agnostic and independent of the checkout layout would let downstream packagers run it as-is (this recipe excludes those files and the GPU-only cases in its test). |

This recipe sidesteps the build-time wheel layout by pip-installing each `source/*` under its own name (a plain package, not the wheel builder's nested `__path__` shell) and vendoring `apps/` and `scripts/` under `$PREFIX/share/isaaclab` (with `patches/0001-conda-forge-path-adjustments.patch` redirecting the lookups). The base `__init__.py` still calls `_deprioritize_prebundle_paths()` on import, but with no Isaac Sim present it finds nothing to demote and returns early, so it is left as shipped. The explicit `isaaclab = isaaclab.cli:cli` entry point is kept even though `pip` already installs it from `source/isaaclab/pyproject.toml`, as a small robustness net across platforms (e.g. a future Windows build).

## Local validation

A render-only pass checks that the recipe parses and the outputs resolve:

```bash
rattler-build build --recipe recipe.yaml --target-platform linux-64 --render-only
```

For an actual build plus smoke test, `pixi.toml` in this directory is self-contained: it builds `isaaclab-all` from `recipe.yaml` as a source dependency (`pixi-build-rattler-build`), so pixi materializes the artifact itself with no local channel to seed first.

```bash
pixi run plain            # build, resolve and run the Newton idle smoke
pixi run -e ovrtx ovrtx   # same, plus the PyPI-only Omniverse RTX backends
```

Both tasks pull one closed-source wheel from `pypi.nvidia.com`: `omniverseclient`, because the Nucleus/S3 USD assets are fetched through `omni.client` even for a Newton idle run (this is the packaging blocker called out under [Worth upstreaming](#worth-upstreaming)). The `ovrtx` env adds `ovrtx` and `ovstage` on top for the RTX renderer. Everything else comes from conda-forge. A `glibc 2.35` custom platform is set so those `manylinux_2_35` wheels resolve, and the platform pins `cuda 13` so the CUDA PyTorch the examples need resolves out of the box.

The base `isaaclab` output also runs upstream's `unit` suite against the installed package (`tests` in `recipe.yaml`). It tries to pull `omniverseclient` from `pypi.nvidia.com` into the test env (a few `unit` tests import `omni.client`) and excludes only the tests that read the source checkout, see the [Worth upstreaming](#worth-upstreaming) note. The run is device-aware: it detects the GPU with `torch.cuda.is_available()` and runs the `cuda`-parametrized tests (and `deps/test_torch.py`) only on the cuda runners, falling back to the CPU-only subset elsewhere. The `omniverseclient` install is best-effort: its `manylinux_2_35` wheel loads only where `glibc >= 2.35`, so on the staged-recipes alma9 image (`glibc 2.34`) it is skipped along with the two tests that import `omni.client`, while locally the whole set runs. This is a local-first extra.

## Files

- `recipe.yaml`: the recipe.
- `gen_recipe_deps.py`: helper to re-derive the deps for a revision.
- `pixi.toml`: self-contained local build plus smoke test.
- `README.md`: this file.

`gen_recipe_deps.py`, `pixi.toml` and `README.md` are maintainer tooling. Prune or relocate them before the recipe is actually submitted for merge if conda-forge review asks for it.
