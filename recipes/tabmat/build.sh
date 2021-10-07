#!/bin/bash

set -euo pipefail

python -m pip install . --no-deps --ignore-installed -vv --no-use-pep517 --disable-pip-version-check
