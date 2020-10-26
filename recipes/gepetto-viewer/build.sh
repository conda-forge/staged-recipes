#!/bin/sh

# OSX fix for X11 / tk 
if [[ "$OSTYPE" == "darwin"* ]]; then
  # In the case of macOs include/X11 are the fake ones from tk
  # which is needed due to other dependencies. However we have
  # the good ones in the include folder of the host. So to let
  # the compiler take the good ones, we alias the wrong header
  # folder during compilation then restore it as it was.
  # We can't use CMAKE_IGNORE_PATH as the include folder is used
  # for other dependencies.
  # This fix is inspired from @pkgw (https://github.com/pkgw) in
  # https://github.com/conda-forge/tk-feedstock/pull/16 and adapted
  # to take advantage of the presence of isolated X11 header in build
  export X11_PATH=$PREFIX/include/X11
  export X11_ALIAS_PATH=$PREFIX/include/tk_X11
  mv $X11_PATH $X11_ALIAS_PATH
fi

mkdir build
cd build
cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_CXX_FLAGS=-std=gnu++11
make -j${CPU_COUNT} 
make install

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Restore the fix
  mv $X11_ALIAS_PATH $X11_PATH
fi
