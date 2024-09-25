#!/bin/bash
set -x -e

# First build the python library w/o installing headers.
export WF_SKIP_HEADER_INSTALL=skip
# See: https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
$PYTHON -m pip install . -vv --no-deps --no-build-isolation

# Then install just the runtime headers.
# CMake can't install a single target, so we do this manually.
mkdir $PREFIX/include/wrenfold
cp components/runtime/wrenfold/*.h $PREFIX/include/wrenfold/
cp LICENSE $PREFIX/include/wrenfold/
