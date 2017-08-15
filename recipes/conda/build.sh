#!/bin/bash

# Remove symlinks
unlink $PREFIX/bin/conda
unlink $PREFIX/bin/activate
unlink $PREFIX/bin/deactivate

# Prep conda install
export CONDA_DEFAULT_ENV=''
echo "${PKG_VERSION}" > conda/.version

# Install the Python code
$PYTHON conda.recipe/setup.py install

# Install the fish activation script.
mkdir -p $PREFIX/etc/fish/conf.d/
cp $SRC_DIR/shell/conda.fish $PREFIX/etc/fish/conf.d/
