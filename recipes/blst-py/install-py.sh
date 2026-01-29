#!/usr/bin/env bash

set -ex

# Install
pushd "${SRC_DIR}"/bindings/python
  ${PYTHON} -m pip install . \
    --no-build-isolation \
    --no-deps \
    --only-binary :all: \
    --prefix "${PREFIX}"

  # Prepare test script
  ${PYTHON} "${RECIPE_DIR}"/helpers/extract_test_run.me.py > "${SRC_DIR}"/test_blst.py
popd
