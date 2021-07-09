mkdir build
cd build

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake .. \
	-G "Ninja" \
	-DCMAKE_BUILD_TYPE=Release \
	-DVCPKG_DEVELOPMENT_WARNINGS=OFF \
	${CMAKE_ARGS}

ninja
# ninja test

mkdir -p $PREFIX/bin/
mv vcpkg $PREFIX/bin/