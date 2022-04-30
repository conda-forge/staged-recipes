#!/usr/bin/env bash
set -ex

mkdir scine_sparrow/
sed \
  -e s/@Sparrow_VERSION@/$PKG_VERSION/ \
  -e s/@sparrow_PY_DEPS@// \
  src/Sparrow/Python/setup.py > setup.py
cp -r src/Sparrow/Python/__init__.py scine_sparrow/
pip install . -vv
