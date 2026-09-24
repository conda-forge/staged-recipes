#!/bin/bash

cd pymodule
export CMAKE_GENERATOR=Ninja
$PYTHON -m pip install \
    --no-deps \
    --no-build-isolation \
    -vv \
    -C 'skbuild.ninja.make-fallback=false' \
    -C 'cmake.define.NANOVDB_EDITOR_USE_GLFW=OFF' \
    -C 'cmake.define.NANOVDB_EDITOR_BUILD_TESTS=OFF' \
    .
