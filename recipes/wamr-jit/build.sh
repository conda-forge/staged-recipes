#!/usr/bin/env bash
set -euxo pipefail

exec bash "$RECIPE_DIR/../wamr/build-wamr.sh" jit
