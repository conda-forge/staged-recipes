# stage 1, library
mkdir _build
cd _build

cmake -DODE_WITH_DEMOS:BOOL=OFF \
      -DODE_WITH_TESTS:BOOL=OFF .. \
      -DCMAKE_INSTALL_PREFIX:PATH="" \
      -DCMAKE_INSTALL_LIBDIR="lib"

make VERBOSE=1
make install DESTDIR="${PREFIX}"
cd ..

# stage 2, bindings

# make sure recently installed ode.pc is found
PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:

# code has aliasing warnings, use flag to prevent crashes
CFLAGS="-fno-strict-aliasing $CFLAGS"
cd bindings/python
${PYTHON} setup.py install --root "${PREFIX}" --prefix ""
