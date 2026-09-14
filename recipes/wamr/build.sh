#!/usr/bin/env bash
set -euxo pipefail

exec bash "$RECIPE_DIR/build-wamr.sh" interp
