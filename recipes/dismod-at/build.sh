#! /usr/bin/env bash
echo "build.sh: pwd = $(pwd)"
#
# extra_cxx_flags
extra_cxx_flags='-Wpedantic -std=c++17 -Wall -Wshadow -Wconversion'
extra_cxx_flags+=' -Wno-bitwise-instead-of-logical'
if [[ "${target_platform}" == osx-* ]]; then
   # https://conda-forge.org/docs/maintainer/knowledge_base.html#
   #  newer-c-features-with-old-sdk
   extra_cxx_flags+=" -D_LIBCPP_DISABLE_AVAILABILITY"
fi
extra_cxx_flags+=' -Wno-sign-conversion'
#
# build
mkdir build && cd build
#
# cmake
cmake -S $SRC_DIR -B . \
   -G 'Ninja' \
   -D CMAKE_BUILD_TYPE=Release \
   -D extra_cxx_flags="'$extra_cxx_flags'" \
   -D dismod_at_prefix="$PREFIX" \
   -D cmake_libdir=lib \
   -D python3_executable="python3"
#
# build
# dismod_at C++ executable
ninja -j$CPU_COUNT dismod_at
#
# build
# dismod_at unit tests (developer tests) can be built in parallel
ninja -j$CPU_COUNT example_devel test_devel
#
# 
# check
# This target does not support parallel execution because many of the 
# user tests use the same file name.
ninja -j1 check
#
# C++ install
ninja -j$CPU_COUNT install
#
# python install
python -m pip install $SRC_DIR/python  -vv --no-deps --no-build-isolation
python -m pip show dismod_at
#
echo 'build.sh: OK'
