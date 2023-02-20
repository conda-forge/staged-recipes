@ECHO ON

cmake %CMAKE_ARGS% ^
      -G "Ninja" ^
      -S %SRC_DIR% ^
      -B build ^
      -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_C_COMPILER=clang-cl ^
      -D CMAKE_CXX_COMPILER=clang-cl ^
      -D CMAKE_C_FLAGS="/wd4018 /wd4101 /wd4996 %CFLAGS%" ^
      -D CMAKE_CXX_FLAGS="/wd4018 /wd4101 /wd4996 %CXXFLAGS%" ^
      -D CMAKE_INSTALL_LIBDIR="lib" ^
      -D CMAKE_INSTALL_INCLUDEDIR="include" ^
      -D CMAKE_INSTALL_BINDIR="bin" ^
      -D CMAKE_INSTALL_DATADIR="share" ^
      -D BUILD_SHARED_LIBS=OFF ^
      -D Eigen3_ROOT=%PREFIX% ^
      -D ENABLE_XHOST=OFF ^
      -D LIBINT2_REQUIRE_CXX_API=ON ^
      -D LIBINT2_REQUIRE_CXX_API_COMPILED=OFF ^
      -D LIBINT2_ENABLE_FORTRAN=OFF ^
      -D LIBINT2_ENABLE_PYTHON=OFF ^
      -D BUILD_TESTING=OFF ^
      -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

:: use `--target check install` above to run ctest tests within build phase. adds about 10m. also have to BUILD_TESTING=ON

cd build
cmake --build . ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1
