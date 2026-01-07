
cmake %CMAKE_ARGS% ^
  -G "Ninja" ^
  -S %SRC_DIR% ^
  -B build ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -D CMAKE_C_FLAGS="%CFLAGS%" ^
  -D CMAKE_Fortran_FLAGS="%FFLAGS%" ^
  -D BUILD_SHARED_LIBS=ON ^
  -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
  -D CMAKE_GNUtoMS=ON ^
  -D OpenTrustRegion_BUILD_TESTING=ON ^
  -D CMAKE_VERBOSE_MAKEFILE=OFF ^
  -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

cmake --build build ^
      --config Release ^
      --target install
if errorlevel 1 exit 1

:: testing library built here is used in py: opentrustregion.testsuite

:: in case need to inspect DLL contents again in future,
::   (needs opentrustregion/requirements/build: - binutils  # [win])
::   objdump.exe -p build\libopentrustregion_32.dll | findstr /i "init_solver_setting"
