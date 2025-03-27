
cmake %CMAKE_ARGS% ^
  -G "Ninja" ^
  -S %SRC_DIR% ^
  -B build ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX="%PREFIX%" ^
  -D CMAKE_INSTALL_LIBDIR="Library\lib" ^
  -D CMAKE_INSTALL_INCLUDEDIR="Library\include" ^
  -D CMAKE_INSTALL_BINDIR="Library\bin" ^
  -D CMAKE_INSTALL_DATADIR="Library\share" ^
  -D CMAKE_CXX_FLAGS="%CXXFLAGS%" ^
  -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
  -D BUILD_SHARED_LIBS=ON ^
  -D INTEGRATORXX_ENABLE_TESTS=ON ^
  -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

      ::-DCMAKE_CXX_FLAGS="/wd4018 /wd4101 /wd4996 /EHsc %CXXFLAGS%"
      ::-DLAPACK_LIBRARIES="%PREFIX%/Library/lib/mkl_rt.lib"

cmake --build build ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

cd build
ctest --rerun-failed --output-on-failure
if errorlevel 1 exit 1

