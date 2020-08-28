#!/bin/bash

bazel build src/python:bindings_test
cp -f ./bazel-bin/src/bindings/_pydp.so ./pydp
rm -rf dist 
$PYTHON setup.py bdist_wheel
$PYTHON -m pip install --no-deps dist/*.whl
