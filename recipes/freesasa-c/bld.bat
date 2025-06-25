@echo on

.\configure --prefix=%PREFIX% ^
    --enable-shared ^
    --disable-static ^
    --disable-debug ^
    --disable-dependency-tracking ^
    --enable-silent-rules ^
    --disable-option-checking

make -j%CPU_COUNT%
make install
