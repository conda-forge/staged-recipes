#!/bin/sh

cmake -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DPython_FIND_STRATEGY=LOCATION \
  -DPython_ROOT_DIR=${PREFIX} \
  -DSWIG_COMPILE_FLAGS="-O1 -DPy_LIMITED_API=0x030A0000" -DUSE_PYTHON_SABI=ON \
  -B build .

cmake --build build --target install --parallel ${CPU_COUNT}

if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  ctest --test-dir build -R pyinstallcheck --output-on-failure -j${CPU_COUNT}
fi
