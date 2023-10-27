#!/usr/bin/env bash

set -ex

autoreconf_args=(
  --force
  --install
  --verbose
)

configure_args=(
  --prefix=$PREFIX
)

if [[ "$target_platform" == win-64 ]]; then
  # set default include and library dirs for Windows build
  export CPPFLAGS="$CPPFLAGS -isystem $PREFIX/include"
  export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
  # to pick up pkg-config macros
  autoreconf_args+=(
    -I "$BUILD_PREFIX/Library/mingw-w64/share/aclocal"
  )
  # so we can find packages with pkg-config (e.g. fftw)
  export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig
  # so we can make shared libs without overzealous checking
  export lt_cv_deplibs_check_method=pass_all
fi

autoreconf "${autoreconf_args[@]}"
./configure "${configure_args[@]}"
make V=1 -j${CPU_COUNT}
make install

# remove static library
rm $PREFIX/lib/libosmodsp.a*
