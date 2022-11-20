sh .\autogen.sh
sh .\configure --prefix=%LIBRARY_PREFIX% --disable-static --enable-shared
make -j%CPU_COUNT%
make install

del %LIBRARY_LIB%\libzimg.a
