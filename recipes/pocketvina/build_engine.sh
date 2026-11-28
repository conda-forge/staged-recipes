#!/usr/bin/env bash
# Build script of the conda package pocketvina-engine (recipe.yaml): compiles the PocketVina-GPU docking engine with
# conda-forge's C++ compiler, Boost (shared libraries) and OpenCL ICD loader and headers, and installs it with
# pocketvina/Makefile's `make install` as $PREFIX/bin/pocketvina-engine, with the OpenCL kernel sources it compiles
# at its first run on a GPU in $PREFIX/share/pocketvina/OpenCL (pocketvina.engine finds both there).
# CXX, CXXFLAGS and LDFLAGS come from the compiler package's activation (the Makefile takes them from the
# environment); BOOST_ROOT and OPENCL_ROOT are the host prefix, where libboost-devel, ocl-icd and opencl-headers are.
set -euxo pipefail

cd pocketvina
# a source tree may hold a prebuilt engine (git checkout, sdist): never package that one, always this build's
rm -f PocketVina-GPU

make print BOOST_ROOT="$PREFIX" OPENCL_ROOT="$PREFIX"
make BOOST_ROOT="$PREFIX" OPENCL_ROOT="$PREFIX"
make install PREFIX="$PREFIX"
