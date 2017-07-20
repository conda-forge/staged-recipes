set -e

mkdir build
cd build

# figure out include / library paths
# https://github.com/conda/conda-build/issues/2130 will be proper solution
pyinc=$($PYTHON -c "from distutils import sysconfig; print(sysconfig.get_python_inc())")
if [[ $(uname) == "Darwin" ]]; then
    pylib=$(otool -L $PYTHON | grep 'libpython.*\.dylib' | tr '\t' ' ' | cut -d' ' -f2 | sed "s|@rpath|$PREFIX/lib|")
else
    pylib=$(ldd $PYTHON | grep $PREFIX | grep 'libpython.*\.so' | cut -d' ' -f3)
fi

cmake .. \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_META_EXAMPLES=OFF \
    -DENABLE_TESTING=OFF \
    -DENABLE_COVERAGE=OFF \
    -DUSE_SVMLIGHT=OFF \
    -DSWIG_EXECUTABLE=$PREFIX/bin/swig \
    -DLIBSHOGUN=OFF \
    -DPYTHON_INCLUDE_DIR=$pyinc \
    -DPYTHON_LIBRARY=$pylib \
    -DPYTHON_EXECUTABLE=$PYTHON \
    -DPythonModular=ON
make -j $CPU_COUNT
make install -j $CPU_COUNT
