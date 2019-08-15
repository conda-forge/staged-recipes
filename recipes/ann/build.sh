if [ "$(uname)" == "Darwin" ];
then
    export CC=clang
    export CXX=clang++

    export MACOSX_VERSION_MIN=10.7
    export CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    export LINKFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export LINKFLAGS="${LINKFLAGS} -stdlib=libc++ -std=c++11 -L${LIBRARY_PATH}"
fi


cmake -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}\
    -DCMAKE_PREFIX_PATH=${PREFIX}\
    -DBUILD_SHARED_LIBS=ON .

make -j${CPU_COUNT}
make install