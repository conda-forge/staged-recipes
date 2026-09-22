#!/usr/bin/env bash
set -ex

# meson.build rejects optimization=3, which --buildtype=release sets
meson setup builddir ${MESON_ARGS} -Doptimization=2 -Ddebug=false
meson compile -C builddir -v pestutils

# place the shared library where pypestutils.finder looks first
mkdir -p pypestutils/lib
cp builddir/pestutils/libpestutils${SHLIB_EXT} pypestutils/lib/

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

# run the upstream test suite here, since its 77 MB of data files are too
# large to ship as package test files; tests use paths relative to the repo
# root, so remove its source package to import the installed one instead
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  cd upstream
  rm -rf pypestutils
  ${PYTHON} -m pytest tests -p no:cacheprovider
fi
