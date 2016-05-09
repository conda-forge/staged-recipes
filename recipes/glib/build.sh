#!/usr/bin/env bash

# Need to get appropriate response to g_get_system_data_dirs()
# See the system-data-dirs.patch file
export CFLAGS="-DCONDA_SYSTEM_DATA_DIRS=\\\"${PREFIX}/share\\\""

if [ "$(uname)" == "Darwin" ] ; then
  # for Mac OSX
  export CC=clang
  export CXX=clang++
  # Cf. the discussion in meta.yaml -- we require 10.7.
  export MACOSX_DEPLOYMENT_TARGET="10.7"
  SDK=/
  export CFLAGS="${CFLAGS} -isysroot ${SDK}"
  export LDFLAGS="${LDFLAGS} -Wl,-syslibroot,${SDK}"
  # Pick up the Conda version of gettext/libintl:
  export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
  export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
else
  # for linux
  # Pick up the Conda version of gettext/libintl:
  export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
  export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
fi

./configure --prefix=${PREFIX} --with-python="${PYTHON}" --with-libiconv=gnu \
  || { cat config.log; exit 1; }
make
make install
