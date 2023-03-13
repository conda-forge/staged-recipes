#!/bin/bash

set -e
# use autotools build for now because cmake build doesn't install pkg-config files
# but I suspect that the older build flow will install cmake files correctly
# https://github.com/accellera-official/systemc/blob/39740075f47fedbce242808d357fcfb6d3d33957/cmake/INSTALL_USING_CMAKE#L421-L422
# Just running configure with 2.3.4, it complains about not finding Makefile.in so
# rerun autotools to generate the automake outputs
autoreconf --install --force

mkdir build
cd build
../configure \
    --prefix="$PREFIX" \
    --with-unix-layout \
    --with-pthreads \
    --with-arch-suffix='' # conda doesn't do multilib, everything in a prefix is for one target arch

make -j $CPU_COUNT

# We run all of these tests with the installed package. So, typically we don't run them here
# However, it might be useful to know they pass in the build when debugging a failure. In that case
# uncomment below.
#make -j $CPU_COUNT check

make install

# create activate & deactivate scripts that manage SYSTEMC_HOME
mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d

sed 's/\@NATURE\@/activate/' "${RECIPE_DIR}"/activate.sh > "${PREFIX}"/etc/conda/activate.d/activate-${PKG_NAME}.sh
sed 's/\@NATURE\@/deactivate/' "${RECIPE_DIR}"/activate.sh > "${PREFIX}"/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh

