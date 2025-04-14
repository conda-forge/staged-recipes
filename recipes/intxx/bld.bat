echo %LDFLAGS%
set "LDFLAGS=%LDFLAGS:/link=%"
echo %LDFLAGS%

cmake %CMAKE_ARGS% ^
  -G "Ninja" ^
  -S %SRC_DIR% ^
  -B build ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
  -D BUILD_SHARED_LIBS=ON ^
  -D INTEGRATORXX_ENABLE_TESTS=ON ^
  -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

cmake --build build ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

cd build
ctest --rerun-failed --output-on-failure -E SPH_GEN
if errorlevel 1 exit 1

:: apparently a .NET issue? skipping for now
:: QUADRATURES_SPH_GEN ..............Exit code 0xc0000135
