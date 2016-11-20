if [ "$(uname)" == "Darwin" ];
then
    # Switch to clang with C++11 ASAP.
    export MACOSX_VERSION_MIN=10.7
    export CC=clang
    export CXX=clang++
    export CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11 -I${PREFIX}/include"
    export LIBS="-lc++"
elif [ "$(uname)" == "Linux" ];
then
    export CC=gcc
    export CXX=g++
fi

./configure --prefix="${PREFIX}" \
        CC="${CC}" \
        CXX="${CXX}" \
        CXXFLAGS="${CXXFLAGS}" \
        LDFLAGS="${LDFLAGS}"
make
make -j"${CPU_COUNT}"
make install
