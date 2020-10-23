
	cmake ../.. ^
		-DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
		-DCMAKE_TOOLCHAIN_FILE=%TOOLCHAIN% ^
		-DVCPKG_TARGET_TRIPLET=%TRIPLET% ^
		-DCMAKE_GENERATOR_PLATFORM=%ARCH%
)

:: Build and install solution
cmake --build . --target INSTALL --config %BUILD_TYPE%

popd

