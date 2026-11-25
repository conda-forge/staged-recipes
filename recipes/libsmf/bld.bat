@echo on
setlocal enabledelayedexpansion

cmake -S solver -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DSMF_USE_MKL=OFF ^
  -DSMF_USE_SUITESPARSE_AMD=ON ^
  -DSMF_USE_METIS=ON ^
  -DSMF_VENDORED_METIS=ON ^
  -DSMF_BUILD_C_API=ON ^
  -DSMF_BUILD_MA97_PLUGIN=ON ^
  -DSMF_BUILD_TESTS=OFF ^
  -DSMF_BUILD_BENCHMARKS=OFF ^
  -DSMF_MSVC_ARCH=
if errorlevel 1 exit 1

cmake --build build -j %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1

REM Follow CFEP-18: remove static libraries (keep smf_c.lib / smf_ma97.lib DLL import libs).
if exist "%LIBRARY_LIB%\smf.lib" del /q "%LIBRARY_LIB%\smf.lib"
if exist "%LIBRARY_LIB%\smf_metis.lib" del /q "%LIBRARY_LIB%\smf_metis.lib"
if exist "%LIBRARY_LIB%\cmake\smf" rmdir /s /q "%LIBRARY_LIB%\cmake\smf"
