cmake -S . -B build ^
         -G Ninja ^
         -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DSFCGAL_BUILD_TESTS=OFF ^
	 -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
	 -DCMAKE_UNITY_BUILD=ON ^
	 -DCMAKE_UNITY_BUILD_BATCH_SIZE=16 ^
	 -DCMAKE_CXX_FLAGS="/bigobj" ^
         -Wno-dev
cmake --build build --config Release
cmake --install build

