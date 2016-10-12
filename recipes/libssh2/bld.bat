mkdir build && cd build

cmake .. -G "NMake Makefiles"                  ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%    ^
	-DCMAKE_BUILD_TYPE=Release                 ^
	-DBUILD_SHARED_LIBS=OFF

cmake --build . --config Release --target INSTALL
