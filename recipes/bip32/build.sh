#!/bin/bash

set -eox pipefail

${PYTHON} -m pip install --use-pep517 . -vvv
