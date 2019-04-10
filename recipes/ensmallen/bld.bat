mkdir -p build
pushd build

cmake -G "Ninja" \
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% \
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% \
      ..

ninja
ninja install
