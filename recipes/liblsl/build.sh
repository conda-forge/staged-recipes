cmake $CMAKE_ARGS \
	-DCMAKE_BUILD_TYPE=Release \
	-DLSL_BUNDLED_PUGIXML=OFF \
	-DLSL_UNIXFOLDERS=ON \
	-S . -B build
cmake --build build --config Release -j --target install
