mkdir build
cd build

cmake .. ^
	%CMAKE_ARGS% ^
	-DBUILD_SHARED=ON ^
	-DBUILD_STATIC=OFF ^
	-DBUILD_BINDINGS=OFF ^
	-G "Ninja"

ninja install