
set BUILD_TYPE=Release

	cmake ../.. ^
		-G "Visual Studio 15 2017"  ^
		-DCMAKE_BUILD_TYPE=$BUILD_TYPE ^
		-DCMAKE_INSTALL_PREFIX=$PREFIX ^
		-DCMAKE_LIBRARY_PATH=$PREFIX/lib ^
		-DCMAKE_INCLUDE_PATH=$PREFIX/include ^
		-DCONDA_BUILD=ON
)

:: Build and install solution
cmake --build . --target INSTALL --config %BUILD_TYPE%
