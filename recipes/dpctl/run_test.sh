#!/bin/bash

set -e

${PYTHON} -c "import dpctl"
python -m pytest -q -ra --disable-warnings --cov dpctl --cov-report term-missing --pyargs dpctl -vv
