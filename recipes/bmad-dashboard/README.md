# bmad-dashboard conda-forge recipe

Builds the [BMAD Dashboard](https://github.com/elvince/bmad-dashboard-extension) VS Code extension from source and ships the resulting `.vsix` plus a `bmad-dashboard-install` helper that wraps `code --install-extension`.

## Per-version vendoring workflow

This recipe builds fully offline — `pnpm install --offline` resolves every dependency from a pre-fetched pnpm store supplied as an additional `source:` entry. It must be regenerated and re-uploaded for every version bump.

1. Download and extract the upstream source tarball pinned in `recipe.yaml`:
   ```bash
   VERSION=1.3.0
   curl -L "https://github.com/elvince/bmad-dashboard-extension/archive/refs/tags/v${VERSION}.tar.gz" | tar -xz
   cd "bmad-dashboard-extension-${VERSION}"
   ```
2. Run `vendor.sh` from inside that tree (needs `node >=22`, `pnpm >=10`, `tar`):
   ```bash
   bash /path/to/recipes/bmad-dashboard/vendor.sh "${VERSION}"
   ```
3. Upload `bmad-dashboard-pnpm-store-${VERSION}.tar.gz` to a stable HTTPS host. The recipe URL defaults to `github.com/rxm7706/conda-recipes-vendored/releases/download/bmad-dashboard-${VERSION}/`; change `recipe.yaml` if you use a different host.
4. Paste the SHA256 value printed by `vendor.sh` into `recipe.yaml`'s `source[1].sha256` field, replacing the all-zero placeholder.

## Why vendoring

Conda-forge build sandboxes are inconsistent about network access, and a Vite + esbuild + React 19 build pulls thousands of npm packages on first run. Pre-fetching guarantees a deterministic, reviewable, fully-offline build at the cost of one extra step per version.

## Why VS Code is not a runtime dependency

conda-forge does not ship VS Code, so `vscode` is not in `requirements.run`. The `bmad-dashboard-install` helper is a thin wrapper around `code --install-extension` and requires the user to have installed VS Code (or a compatible editor exposing the `code` CLI: VS Code Insiders, VSCodium, Cursor) on PATH separately.

## Maintenance notes

- The autotick bot will not regenerate the vendor tarball — version bumps must be done manually.
- If `pnpm-lock.yaml` changes between releases, the pre-fetched store will be incomplete and `pnpm install --offline` will fail loud — re-run `vendor.sh`.
- The package internal name (`package.json.name`) is `bmad-dashboard`; the conda package name matches. The repo name `bmad-dashboard-extension` is intentionally not used as the conda package name.
