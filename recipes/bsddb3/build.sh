#!/usr/bin/env bash

export YES_I_HAVE_THE_RIGHT_TO_USE_THIS_BERKELEY_DB_VERSION=1
BERKELEYDB_DIR=$PREFIX $PYTHON -m pip install . --no-deps --ignore-installed
