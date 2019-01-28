#!/bin/bash

$PYTHON -m pip install . --no-deps --ignore-installed -vv

# Install sos kernel for jupyter
# --sys-prefix = $PREFIX/share/jupyter/kernels/sos/
$PYTHON -m sos_notebook.install --sys-prefix
