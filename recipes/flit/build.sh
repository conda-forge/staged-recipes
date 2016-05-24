#!/usr/bin/env bash
# Build might be run as root, but it doesn't matter
set -e

export FLIT_ROOT_INSTALL=1
python -m flit install --env --deps none

which python
cd && python -c "import flit; print(flit)"
