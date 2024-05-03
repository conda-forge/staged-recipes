#!/bin/bash

set -x

export LDFLAGS=${LDFLAGS/-Wl,--as-needed/}

make \
  prefix=${PREFIX} \
  CC="$CC $LDFLAGS" \
  AR=$AR \
  RANLIB=$RANLIB \
  RPM_OPT_FLAGS="$CFLAGS $CPPFLAGS" \
  INCLUDES="$CPPFLAGS" \
  install \
  tests testt testx \
  -j$CPU_COUNT

rm ${PREFIX}/lib/libzio.a

# Testing code taken from
# https://build.opensuse.org/projects/home:dirkmueller:branches:openSUSE:Factory:Rings:1-MinimalX/packages/libzio/files/libzio.spec?expand=1
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  for comp in gzip bzip2 lzma xz zstd
  do
      case $comp in
      gzip) x=g ;;
      bzip2) x=b ;;
      lzma) x=l ;;
      xz) x=x ;;
      zstd) x=s ;;
      esac
      $comp -c < fzopen.3.in > fzopen.test
      ./testt fzopen.test | cmp fzopen.3.in -
      cat fzopen.test | ./tests $x | cmp fzopen.3.in -
      ./testx $x < fzopen.3.in | ./tests $x | cmp fzopen.3.in -
  done
fi
