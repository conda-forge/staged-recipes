#!/bin/bash

bazel clean
bazel build src/python:bindings_test \
  --action_env=PYTHON_BIN_PATH=$PYTHON \
  --action_env=PYTHON_LIB_PATH=$SRC_DIR/pylib/python$CONDA_PY/Include
cp -f ./bazel-bin/src/bindings/_pydp.so ./pydp

$PYTHON setup.py bdist_wheel
$PYTHON -m pip install --no-deps dist/*.whl
