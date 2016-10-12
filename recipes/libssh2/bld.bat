mkdir bin && cd bin
cmake .. ^
	-G "%CMAKE_GENERATOR%"                     ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%    ^
	-DCMAKE_BUILD_TYPE=Release 

cmake --build . --config Release --target INSTALL
cmake --build . --config Release --target RUN_TESTS
