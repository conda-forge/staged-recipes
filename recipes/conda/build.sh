#!/bin/bash

unlink $PREFIX/bin/conda

export CONDA_DEFAULT_ENV=''

echo "${PKG_VERSION}" > conda/.version

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/exec
ln -s $PREFIX/bin/activate $PREFIX/exec/activate
ln -s $PREFIX/bin/conda $PREFIX/exec/conda

mkdir -p $PREFIX/etc/fish/conf.d/
cp $SRC_DIR/shell/conda.fish $PREFIX/etc/fish/conf.d/
