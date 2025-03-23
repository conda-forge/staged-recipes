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
# dismodat.py
file='python/bin/dismodat.py.in'
sed -i "$SRC_DIR/$file" -e 's|@python3_executable@|/usr/bin/env python|'
#
# user_test.sh
file='bin/user_test.sh.in'
sed -i "$SRC_DIR/$file" -e 's|{1..3}|{1..4}|'
#
# build
mkdir build && cd build
#
# cmake
cmake -S $SRC_DIR -B . \
   -G 'Unix Makefiles' \
   -D CMAKE_BUILD_TYPE=Release \
   -D extra_cxx_flags="'$extra_cxx_flags'" \
   -D cmake_install_prefix="$PREFIX" \
   -D dismod_at_prefix="$PREFIX" \
   -D cmake_libdir=lib \
   -D python3_executable="python3"
#
# make
make -j$CPU_COUNT
#
# check
make check
#
# install
make -j$CPU_COUNT install
#
# pip
$PYTHON -m pip install $SRC_DIR/python  -vv --no-deps --no-build-isolation
#
echo 'build.sh: Done: OK'
