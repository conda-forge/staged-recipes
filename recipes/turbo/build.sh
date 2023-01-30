mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
	  -DCMAKE_INSTALL_LIBDIR=lib \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DTURBO_BUILD_TESTING=OFF \
	  -DBUILD_SHARED_LIBS=ON
	  ..
cmake --build .
cmake --build . --target install
