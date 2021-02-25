mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_BUILD_TYPE=%CONFIGURATION% ^
         -DCMAKE_PREFIX_PATH="%PREFIX%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
         -DBOOST_ROOT="%LIBRARY_PREFIX%" ^
         -DBUILD_NIFTY_PYTHON=ON ^
         -DWITH_HDF5=OFF ^
         -DWITH_Z5=OFF ^
         -DPYTHON_EXECUTABLE="%PYTHON%"
REM FIXME z5 builds fail on windows
REM         -DWITH_Z5=ON ^
REM         -DWITH_ZLIB=ON ^
REM         -DWITH_BLOSC=ON ^

cmake --build . --config %CONFIGURATION% --target install
