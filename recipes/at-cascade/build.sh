#! /usr/bin/env bash
set -e -u
echo "build.sh pwd = $(pwd)"
#
# python version
echo 'build.sh: python version = '
"${PYTHON}" --version
#
# Test in sandbox
"${PYTHON}" bin/check_py_test.py
#
# install
"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
#
# install information
"${PYTHON}" -m pip show at_cascade
#
echo 'build.sh: OK'
