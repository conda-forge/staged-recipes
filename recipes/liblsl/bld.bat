cmake -G "%CMAKE_GEN%" ^
	-DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
	-DCMAKE_PREFIX_PATH="%PREFIX%" ^
	-DCMAKE_BUILD_TYPE=Release ^
	-DLSL_BUNDLED_PUGIXML=OFF ^
	-DLSL_UNIXFOLDERS=ON ^
	-S . -B build
cmake --build build --config Release -j --target install
