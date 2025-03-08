#! /usr/bin/env bash
set -e -u
echo "build.sh: Start"
#
# extra_cxx_flags
extra_cxx_flags='-Wpedantic -std=c++11 -Wall -Wshadow -Wconversion'
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
   -G 'Unix Makefiles' \
   -D CMAKE_BUILD_TYPE=Release \
   -D extra_cxx_flags="$extra_cxx_flags" \
   -D cmake_install_prefix="$PREFIX" \
   -D cmake_libdir=lib \
   -D ldlt_cholmod=yes \
   -D optimize_cppad_function=yes \
   -D for_hes_sparsity=yes 
#
# check
make -j$CPU_COUNT check
#
# install
make -j$CPU_COUNT install
#
echo 'build.sh: Done: OK'
