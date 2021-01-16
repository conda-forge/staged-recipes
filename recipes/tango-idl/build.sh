mkdir build
cd build

# Use -DCMAKE_INSTALL_LIBDIR=lib to install tangoidl.pc under lib/pkgconfig
# and not lib64/pkgconfig
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ..
make install
