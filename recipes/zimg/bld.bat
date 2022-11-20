sh .\autogen.sh
sh .\configure --prefix=%PREFIX% --disable-static --enable-shared
make -j%CPU_COUNT%
make install
