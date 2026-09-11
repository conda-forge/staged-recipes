# bmad-dashboard conda-forge recipe

Packages the [BMAD Dashboard](https://github.com/elvince/bmad-dashboard-extension) VS Code extension as a conda-installable bundle: ships the upstream-published `.vsix` plus a cross-platform `bmad-dashboard-install` helper that wraps `code --install-extension`.

## How the recipe works

Upstream's release pipeline publishes a prebuilt `.vsix` on every GitHub release tag (e.g. `v1.3.0/bmad-dashboard-1.3.0.vsix`). The recipe downloads that artifact directly and installs it to `${PREFIX}/share/bmad-dashboard/`, alongside the project's `LICENSE.md`. A small Python helper is installed on `PATH` so users can run:

```bash
bmad-dashboard-install
```

after activating the env, which invokes `code --install-extension` against whichever VS Code-compatible CLI is on `PATH` (use `--cli code-insiders|codium|cursor` to target a different editor).

There is no Node, pnpm, or upstream-source build step — the `.vsix` is consumed as a prebuilt redistributable artifact.

## Why VS Code is not a runtime dependency

conda-forge does not ship VS Code itself, so `vscode` is not in `requirements.run`. The installer helper assumes the user has installed VS Code (or a compatible editor: VS Code Insiders, VSCodium, Cursor) separately and has the corresponding CLI on `PATH`.

## Version bumps

For each new upstream release:

1. Update `context.version` in `recipe.yaml`.
2. Update `source[0].sha256` to the new `.vsix`'s SHA256 (visible on the release page, or compute with `curl -L … | sha256sum`).
3. Update `source[1].sha256` if `LICENSE.md` changed at the new tag (rare).

No vendoring, no offline package caches, no per-version build artifacts to host.
