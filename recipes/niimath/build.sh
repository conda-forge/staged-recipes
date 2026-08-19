#!/bin/bash

# Build against niimath's own src/CMakeLists.txt, bypassing the SuperBuild
# which would attempt to git-clone Cloudflare zlib at build time.
# We use the system (conda-provided) zlib.

# Make OpenMP headers/libs visible on macOS (provided by llvm-openmp)
if [[ $HOST == *linux* ]]; then
	export CFLAGS+=" -fopenmp"
else
	export CFLAGS+=" -Xpreprocessor -fopenmp"
	export LDFLAGS+=" -lomp"
fi

# no quotes around cmake_args https://conda-forge.org/docs/maintainer/knowledge_base/#how-to-enable-cross-compilation
# shellcheck disable=SC2086
cmake -S src -B build \
	-GNinja \
	--no-warn-unused-cli \
	-DZLIB_IMPLEMENTATION:STRING=System \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_POLICY_DEFAULT_CMP0069=NEW \
	-DCMAKE_INTERPROCEDURAL_OPTIMIZATION:BOOL=ON \
	-DUSE_STATIC_RUNTIME:BOOL=OFF \
	${CMAKE_ARGS}

cmake --build build
cmake --install build
