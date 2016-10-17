#!/bin/bash
set -e

cd "$SRC_DIR"

pushd instant/test
python run_tests.py
popd

pushd ufl/test
py.test -v
popd

pushd fiat/test/unit
python test.py
popd

pushd ffc/test/unit
python test.py
popd

pushd dolfin/build/test/unit/python
py.test -v fem/test_form.py
popd
