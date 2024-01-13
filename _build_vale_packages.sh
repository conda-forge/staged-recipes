#!/usr/bin/env bash
set -eux
rm -rf build_artifacts
ruff format recipes/vale-packages
ruff --fix-only recipes/vale-packages
python recipes/vale-packages/_update_recipe.py
conda smithy recipe-lint recipes/vale-packages
conda mambabuild --output-folder=build_artifacts recipes/vale-packages
notify-send vale-packages "is ready"
