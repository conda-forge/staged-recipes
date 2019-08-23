# ln -s ${CC} ${PREFIX}/bin/gcc
# ln -s ${CXX} ${PREFIX}/bin/g++
# ln -s ${GFORTRAN} ${PREFIX}/bin/gfortran

# install doxygen manually

# wget https://github.com/doxygen/doxygen/archive/Release_1_8_16.tar.gz
# tar -vxzf Release_1_8_16.tar.gz
# cd doxygen-Release_1_8_16/
# mkdir build && cd build
# cmake -G "Unix Makefiles" .. #-DCMAKE_INSTALL_PREFIX=$PREFIX
# make
# make install
# cd ../..

# now install openmm

export CMAKE_FLAGS=""
CMAKE_FLAGS+=" -DFFTW_LIBRARY=$PREFIX/lib/libfftw3f.so"
CMAKE_FLAGS+=" -DFFTW_THREADS_LIBRARY=$PREFIX/lib/libfftw3f_threads.so"
CMAKE_FLAGS+=" -DCMAKE_INSTALL_PREFIX=$PREFIX"
CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=${CC}"
# CMAKE_FLAGS+=" -DOPENMM_BUILD_PYTHON_WRAPPERS=ON"
# CMAKE_FLAGS+=" -DOPENMM_PYTHON_STAGING_DIR=$PREFIX/python"

mkdir $PREFIX/build && cd $PREFIX/build
# mkdir -p $PREFIX/lib/python${PY_VER}/site-packages
# mkdir -p $PREFIX/python

cmake $SRC_DIR $CMAKE_FLAGS #-DCMAKE_C_COMPILER=${CC} -DCMAKE_INSTALL_PREFIX=$PREFIX
make
make install

# export LDFLAGS="$LDPATHFLAGS"
# export SHLIB_LDFLAGS="$LDPATHFLAGS"
make install PythonInstall

cp -r $PREFIX/build/python/build/lib.linux-x86_64-3.7/simtk $PREFIX/lib/python3.7/site-packages

# build/python/simtk $PREFIX/lib/python{PY_VER}/site-packages

# rm -rf $PREFIX/python
# mv $BUILD_PREFIX/lib/python${PY_VER}/site-packages $PREFIX/lib/python${PY_VER}/site-packages

# mv $PREFIX/python $PREFIX/lib/python${PY_VER}/site-packages

# rm ${PREFIX}/bin/gcc
# rm ${PREFIX}/bin/g++
# rm ${PREFIX}/bin/gfortran