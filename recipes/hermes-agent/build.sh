#!/usr/bin/env bash
set -exo pipefail

printf 'packages:\n  - apps/shared\n  - ui-tui\n  - ui-tui/packages/*\n  - web\n' > pnpm-workspace.yaml
pnpm import
pnpm install --frozen-lockfile --ignore-scripts
pnpm --dir web build
pnpm --dir ui-tui build
pnpm --filter web --filter hermes-tui licenses list --json --prod | pnpm-licenses generate-disclaimer --json-input -o third-party-licenses.txt
mkdir -p hermes_cli/tui_dist
cp ui-tui/dist/entry.js hermes_cli/tui_dist/
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
