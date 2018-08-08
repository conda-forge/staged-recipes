mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "%CMAKE_GENERATOR%" -DCMAKE_PREFIX_PATH=%PREFIX% ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX" ^
    -DBOOST_ROOT=%LIBRARY_PREFIX% ^
    -DWITH_BLOSC=ON ^
    -DWITH_ZLIB=ON ^
    -DWITH_BZIP2=ON ^
    -DWITH_XZ=ON ^
    -DPYTHON_EXECUTABLE=%PYTHON%

cmake --build . --config %CONFIGURATION%

set PY_VER=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")
xcopy %SRC_DIR%/build/python/z5py %LIBRARY%/lib/python%PY_VER%/site-packages/ /E
