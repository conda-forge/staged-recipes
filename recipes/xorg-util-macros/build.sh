#! /bin/bash

set -e
IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug

# Some X.org packages have config.{guess,sub} too old to properly build on
# 64-bit Windows! Because this package stores generic X.org build helpers, we
# use it to distribute more recent versions of those file. Other X.org
# packages should have this one as a build-time dependency and copy the files
# into their unpacked source directories.

mkdir -p $PREFIX/share/util-macros

for f in config.guess config.sub ; do
    cp -p $RECIPE_DIR/$f .
    cp -p $RECIPE_DIR/$f $PREFIX/share/util-macros/
done

export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig

configure_args=(
    --prefix=$PREFIX
    --disable-dependency-tracking
    --disable-selective-werror
    --disable-silent-rules
)
./configure "${configure_args[@]}"
make -j${CPU_COUNT}
make install
make check
