cmake ${CMAKE_ARGS} -DBUILD_LIBCINT=OFF \
      -DBUILD_LIBXC=OFF \
      -DBUILD_XCFUN=OFF \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_SHARED_LIBS=ON \
      -S pyscf/lib \
      -B build

cmake --build build -j${CPU_COUNT}

echo Displaying source dir

echo ${PROJECT_SOURCE_DIR}

${PYTHON} -m pip install . --no-index -vv --no-deps

rm -rf build
