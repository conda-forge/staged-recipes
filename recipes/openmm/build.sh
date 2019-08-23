export CMAKE_FLAGS=""
CMAKE_FLAGS+=" -DFFTW_LIBRARY=$PREFIX/lib/libfftw3f.so"
CMAKE_FLAGS+=" -DFFTW_THREADS_LIBRARY=$PREFIX/lib/libfftw3f_threads.so"
CMAKE_FLAGS+=" -DCMAKE_INSTALL_PREFIX=$PREFIX"
CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=${CC}"

mkdir $PREFIX/build && cd $PREFIX/build

cmake $SRC_DIR $CMAKE_FLAGS
make
make install
make install PythonInstall

cp -r $PREFIX/build/python/build/lib.linux-x86_64-3.7/simtk $PREFIX/lib/python3.7/site-packages