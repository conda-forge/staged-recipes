mkdir _build
cd _build

cmake -DODE_WITH_DEMOS:BOOL=OFF \
      -DODE_WITH_TESTS:BOOL=OFF .. \
      -DCMAKE_INSTALL_PREFIX:PATH="" \
      -DCMAKE_INSTALL_LIBDIR="lib"

make VERBOSE=1
make install DESTDIR="${PREFIX}"
