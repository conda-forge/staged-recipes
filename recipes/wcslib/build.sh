export CFLAGS='-fPIC'

if [ "$(uname)" == "Darwin" ]; then
        
    export CC=clang
    export CXX=clang++

else
    
    export CC=${PREFIX}/bin/gcc
    export CXX=${PREFIX}/bin/g++

fi

LDFLAGS="-Wl,-rpath,${PREFIX}/lib" ./configure --prefix=$PREFIX --with-cfitsiolib=${PREFIX}/lib --with-cfitsioinc=${PREFIX}/include

make all

make check

make install
