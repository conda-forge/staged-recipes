#!/bin/bash
set -e

cd "$SRC_DIR"

rm -rf $HOME/.instant

pushd instant/test
python run_tests.py
popd

rm -rf $HOME/.instant

pushd ufl/test
py.test -v
popd

rm -rf $HOME/.instant

pushd fiat/test/unit
python test.py
popd

rm -rf $HOME/.instant

pushd ffc/test/unit
python test.py || (
    find $HOME/.instant/error -name '*.log' -print -exec cat '{}' \;
    exit 1
)
popd

rm -rf $HOME/.instant

pushd dolfin/build/test/unit/python
py.test -v fem/test_form.py || (
    find $HOME/.instant/error -name '*.log' -print -exec cat '{}' \;
    exit 1
)
popd
