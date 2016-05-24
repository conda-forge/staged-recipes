#!/usr/bin/env bash
# Build might be run as root, but it doesn't matter
export FLIT_ROOT_INSTALL=1
python -m flit install --env
