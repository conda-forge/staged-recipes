export poppler_cpp_CFLAGS="-I${PREFIX}/include/poppler"
export poppler_cpp_LIBS="${PREFIX}/lib/libpoppler-cpp.so"
export libpcre_CFLAGS="-I${PREFIX}/include"
export libpcre_LIBS="${PREFIX}/lib/libpcre.so"

./configure --prefix=$PREFIX
make
make install
