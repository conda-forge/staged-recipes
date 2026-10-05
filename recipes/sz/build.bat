@echo on

:: HDF5 has no default plugin directory on Windows; use the one other conda-forge HDF5 plugins use.
set "PLUGIN_DIR=%PREFIX:\=/%/lib/hdf5/plugin"

cmake -S . -B build -G Ninja %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_TESTING=OFF ^
    -DBUILD_SZ3_BINARY=ON ^
    -DBUILD_H5Z_FILTER=ON ^
    -DSZ3_USE_BUNDLED_ZSTD=OFF ^
    -DH5Z_SZ3_PLUGIN_INSTALL_DIR="%PLUGIN_DIR%"
if errorlevel 1 exit 1

:: SZ3 falls back to its bundled Zstd when pkg-config finds none; conda-forge's must be used.
findstr /b /c:"ZSTD_FOUND:INTERNAL=1" build\CMakeCache.txt
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1
cmake --install build
if errorlevel 1 exit 1
