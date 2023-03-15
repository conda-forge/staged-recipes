#!/bin/bash

set -ex
# run through configure of autotools build for now because cmake build doesn't install pkg-config files
# and we can generate those by running configure but using cmake for consistent build between
# platforms
# Just running configure with 2.3.4, it complains about not finding Makefile.in so
# rerun autotools to generate the automake outputs
autoreconf --install --force

mkdir build
cd build
../configure \
    --prefix="$PREFIX" \
    --with-unix-layout \
    --with-arch-suffix='' # conda doesn't do multilib, everything in a prefix is for one target arch

mkdir -p "$PREFIX"/lib/pkgconfig/
cp -v  src/*.pc "$PREFIX"/lib/pkgconfig/

cd ..
rm -rf build
mkdir build
cd build


cmake $CMAKE_ARGS \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  ..


make -j $CPU_COUNT VERBOSE=1

# We run all of these tests with the installed package. So, typically we don't run them here
# However, it might be useful to know they pass in the build when debugging a failure. In that case
# uncomment below.
#make -j $CPU_COUNT check

make install

# The cmake build doesn't install the examples into the docdir but we
# want to put them in a separate package and run them for testing the package
# without needing to have them in the package metadata. So, install them
cp -r "$SRC_DIR"/examples "$PREFIX"/share/doc/systemc/

# create activate & deactivate scripts that manage SYSTEMC_HOME
mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d

sed 's/\@NATURE\@/activate/' "${RECIPE_DIR}"/activate.sh > "${PREFIX}"/etc/conda/activate.d/activate-${PKG_NAME}.sh
sed 's/\@NATURE\@/deactivate/' "${RECIPE_DIR}"/activate.sh > "${PREFIX}"/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh

ls -l $PREFIX/lib/libsystemc*

