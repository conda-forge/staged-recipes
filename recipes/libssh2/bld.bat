mkdir build && cd build
cmake .. ^
	-G "NMake Makefiles"                     ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%    ^
	-DCMAKE_BUILD_TYPE=Release 

cmake --build . --config Release --target INSTALL
