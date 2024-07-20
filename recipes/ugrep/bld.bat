bash .\configure --enable-color ^
    --disable-silent-rules ^
    --disable-debug ^
    --disable-dependency-tracking ^
    --prefix=%LIBRARY_PREFIX%
make
make install
