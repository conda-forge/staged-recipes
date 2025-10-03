cmake -S . -B build ^
         -G Ninja ^
         -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DSFCGAL_BUILD_TESTS=OFF ^
	 -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=OFF ^
	 -DCMAKE_CXX_FLAGS="/DSFCGAL_EXPORTS" ^
	 -DCGAL_USE_GMPXX=OFF ^
         -Wno-dev
cmake --build build --config Release
cmake --install build

