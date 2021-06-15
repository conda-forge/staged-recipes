#!/bin/bash

set -exuo pipefail

export AWS_C_INSTALL=$PREFIX
$PYTHON -m pip install . -vv
