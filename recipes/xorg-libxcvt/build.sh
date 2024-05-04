#!/bin/bash -ex
IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug

# Adopt a Unix-friendly path if we're on Windows (see bld.bat).
[ -n "$PATH_OVERRIDE" ] && export PATH="${PATH:+${PATH}:}${PATH_OVERRIDE}"

# On Windows we want $LIBRARY_PREFIX in both "mixed" (C:/Conda/...) and Unix
# (/c/Conda) forms, but Unix form is often "/" which can cause problems.
if [ -n "$LIBRARY_PREFIX_M" ] ; then
    mprefix="$LIBRARY_PREFIX_M"
    if [ "$LIBRARY_PREFIX_U" = / ] ; then
        uprefix=""
    else
        uprefix="$LIBRARY_PREFIX_U"
    fi
    if [ "$BUILD_PREFIX_M" = / ] ; then
        bmprefix=""
    else
        bmprefix="$BUILD_PREFIX_M"
    fi
    if [ "$BUILD_PREFIX_U" = / ] ; then
        buprefix=""
    else
        buprefix="$BUILD_PREFIX_U"
    fi
else
    mprefix="$PREFIX"
    uprefix="$PREFIX"
    bmprefix="$BUILD_PREFIX"
    buprefix="$BUILD_PREFIX"
fi

# Cf. https://github.com/conda-forge/staged-recipes/issues/673, we're in the
# process of excising Libtool files from our packages. Existing ones can break
# the build while this happens. We have "/." at the end of $uprefix to be safe
# in case the variable is empty.
find $uprefix/. -name '*.la' -delete

mkdir build
pushd build

export XDG_DATA_DIRS=${XDG_DATA_DIRS}:$uprefix/share:$buprefix/share
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$uprefix/lib/pkgconfig:$buprefix/lib/pkgconfig
EXTRA_FLAGS=""
if [[ $CONDA_BUILD_CROSS_COMPILATION == "1" ]]; then
  EXTRA_FLAGS="--cross-file $bmprefix/meson_cross_file.txt"
fi

meson setup --prefix=$mprefix --buildtype=release --libdir=$mprefix/lib $EXTRA_FLAGS ..
ninja -j${CPU_COUNT}
ninja install

rm -rf $uprefix/share/man $uprefix/share/doc/xcvt

# Remove any new Libtool files we may have installed. It is intended that
# conda-build will eventually do this automatically.
find $uprefix/. -name '*.la' -delete
