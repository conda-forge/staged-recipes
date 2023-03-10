if [[ $(uname) == 'Darwin' ]]; then
    CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
else
    CXXFLAGS="${CXXFLAGS} -std=c++11"
fi

mkdir build
cd build
cmake ..\
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DPYTHON_EXECUTABLE=${PYTHON} \
##

make -j${CPU_COUNT}

make install
