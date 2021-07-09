#!/bin/bash

## Set variables
PLATFORM=$(python scripts/get_platform.py)

# Search specific python bin and lib folders to compile against the poetry env
PYTHONHOME=$(which python)
PYTHONPATH=$(python -c 'import sys; print([x for x in sys.path if "site-packages" in x][0]);')

# Give user feedback
echo -e "Running bazel with:\n\tPLATFORM=$PLATFORM\n\tPYTHONHOME=$PYTHONHOME\n\tPYTHONPATH=$PYTHONPATH"

# Compile code
bazel coverage src/python:pydp \
--config $PLATFORM \
--verbose_failures \
--action_env=PYTHON_BIN_PATH=$PYTHONHOME \
--action_env=PYTHON_LIB_PATH=$PYTHONPATH

# Delete the previously compiled package and copy the new one
rm -f ./src/pydp/_pydp.so
cp -f ./bazel-bin/src/bindings/_pydp.so ./src/pydp
