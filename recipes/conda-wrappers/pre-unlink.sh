#!/bin/bash

CREATE_WRAPPERS_COMMAND=create-wrappers

if [[ "$PKG_NAME" == "conda-wrappers" ]]; then
    # It is a conda build environment or it is being installed with
    # "conda install -n env_name conda-wrappers"
    ENV_DIR="$PREFIX"
    # In this case the environment is not always properly activated, so
    # create-wrappers will not be on PATH
    CREATE_WRAPPERS_COMMAND="$PREFIX/bin/create-wrappers"
elif [[ ! -z "$CONDA_PREFIX" ]]; then
    # regular env on newer conda versions
    ENV_DIR="$CONDA_PREFIX"
elif [[ ! -z "$CONDA_ENV_PATH" ]]; then
    # variable that is set on older conda versions
    ENV_DIR="$CONDA_ENV_PATH"
elif [[ ! -z "$CONDA_DEFAULT_ENV" ]]; then
    # variable that is set on older conda versions
    ENV_DIR="$CONDA_DEFAULT_ENV"
else
    ENV_DIR="`conda info --root`"
    echo ''
    echo 'None of CONDA_PREFIX, CONDA_DEFAULT_ENV, CONDA_ENV_PATH are set. Assuming conda root env' > $ENV_DIR/.messages.txt
fi

BIN_DIR="$ENV_DIR/bin"
WRAPPERS_DIR="$BIN_DIR/wrappers/conda"

echo "Removing wrappers from $WRAPPERS_DIR" > $ENV_DIR/.messages.txt
rm -rf "$WRAPPERS_DIR"
