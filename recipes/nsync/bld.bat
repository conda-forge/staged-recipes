cmake -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	  -DCMAKE_EXE_LINKER_FLAGS="-pthread -lrt"
make -j%CPU_COUNT%
make install
