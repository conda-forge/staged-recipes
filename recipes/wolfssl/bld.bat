@echo on
setlocal EnableDelayedExpansion

mkdir build || exit 1
cd build || exit 1

:: The unit tests are behind WOLFSSL_EXAMPLES in CMakeLists.txt

cmake -GNinja ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
	  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
	  -DCMAKE_BUILD_TYPE=Release ^
	  -DWOLFSSL_REPRODUCIBLE_BUILD=yes ^
	  -DWOLFSSL_EXAMPLES=yes ^
	  .. || exit 1

cmake  --build . -j %CPU_COUNT% || exit 1

ctest -N
ctest -j %CPU_COUNT%

REM put the error check back in place for after ctest before merging
::if errorlevel 1 exit 1

cmake --build . --target install || exit 1
