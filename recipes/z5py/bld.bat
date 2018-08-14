mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_BUILD_TYPE:STRING=%CONFIGURATION% ^
         -DCMAKE_PREFIX_PATH:PATH="%PREFIX%" ^
         -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX" ^
         -DBOOST_ROOT:PATH="%LIBRARY_PREFIX%" ^
         -DWITH_BLOSC:BOOL=ON ^
         -DWITH_ZLIB:BOOL=ON ^
         -DWITH_BZIP2:BOOL=ON ^
         -DWITH_XZ:BOOL=ON ^
         -DPYTHON_EXECUTABLE:PATH="%PYTHON%"

cmake --build . --config %CONFIGURATION%

set PY_VER=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")
xcopy %SRC_DIR%/build/python/z5py %LIBRARY%/lib/python%PY_VER%/site-packages/ /E
