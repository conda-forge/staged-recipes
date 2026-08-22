#!/usr/bin/env bash
set -exo pipefail

printf 'packages:\n  - apps/shared\n  - ui-tui\n  - ui-tui/packages/*\n  - web\n' > pnpm-workspace.yaml
pnpm import
pnpm install --frozen-lockfile --ignore-scripts

pnpm --dir web build
pnpm --dir ui-tui build

# Generate notices from the exact production dependencies used for the bundled assets.
pnpm --filter web --filter hermes-tui licenses list --json --prod |
  pnpm-licenses generate-disclaimer --json-input -o third-party-licenses.txt

mkdir -p hermes_cli/tui_dist
cp ui-tui/dist/entry.js hermes_cli/tui_dist/

# This skill's license forbids retaining or distributing it outside Anthropic services.
rm -rf skills/productivity/powerpoint skills/index-cache

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

# setuptools does not preserve these data-file trees in the generated wheel.
mkdir -p "$PREFIX/skills" "$PREFIX/optional-skills"
cp -R skills/. "$PREFIX/skills/"
cp -R optional-skills/. "$PREFIX/optional-skills/"
