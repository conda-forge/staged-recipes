mkdir build
cd build

set CONFIGURATION=Release

rem cmake .. -G "%CMAKE_GENERATOR%" ^
rem          -DCMAKE_BUILD_TYPE:STRING=%CONFIGURATION% ^
rem          -DCMAKE_PREFIX_PATH:PATH="%PREFIX%" ^
rem          -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX" ^
rem          -DBOOST_ROOT:PATH="%LIBRARY_PREFIX%" ^
rem          -DWITH_BLOSC:BOOL=ON ^
rem          -DWITH_ZLIB:BOOL=ON ^
rem          -DWITH_BZIP2:BOOL=ON ^
rem          -DWITH_XZ:BOOL=ON ^
rem          -DPYTHON_EXECUTABLE:PATH="%PYTHON%"

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_BUILD_TYPE=%CONFIGURATION% ^
         -DCMAKE_PREFIX_PATH="%PREFIX%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX" ^
         -DBOOST_ROOT="%LIBRARY_PREFIX%" ^
         -DWITH_BLOSC=ON ^
         -DWITH_ZLIB=ON ^
         -DWITH_BZIP2=ON ^
         -DWITH_XZ=ON ^
         -DWITHIN_TRAVIS=OFF ^
         -DPYTHON_EXECUTABLE=:PATH"%PYTHON%"

cmake --build . --config %CONFIGURATION%

rem set PY_VER=(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")
xcopy %SRC_DIR%/build/python/z5py %LIBRARY%/lib/python%PY_VER%/site-packages/ /E
