#!/usr/bin/env bash
set -euxo pipefail

pwd
ls -al .
$PYTHON -m pip install . -vv
