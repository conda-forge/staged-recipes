$PYTHON -m pip install . --no-deps -vv

mkdir build
cd build
cmake -DBUILD_FOAM_TESTS=OFF                  \
      -DFOAM_USE_TBB=OFF                      \
      -DFOAM_USE_XSIMD=OFF                    \
      -DCMAKE_INSTALL_PREFIX=$PREFIX $SRC_DIR \
      -DCMAKE_INSTALL_LIBDIR=lib
make install