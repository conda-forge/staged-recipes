#!/usr/bin/env bash
set -eux
rm pyproject.toml
${PYTHON} -m pip install --no-deps -vv --install-option="--skip-npm" .
