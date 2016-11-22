mkdir build && cd build

cmake .. -G "Visual Studio 9 2008"                  ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% 

cmake --build . --target INSTALL --config Release
 
