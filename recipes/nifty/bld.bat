mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_BUILD_TYPE=%CONFIGURATION% ^
         -DCMAKE_PREFIX_PATH="%PREFIX%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
         -DBOOST_ROOT="%LIBRARY_PREFIX%" ^
         -DBUILD_NIFTY_PYTHON=ON ^
         -DWITH_HDF5=ON ^
         -DWITH_Z5=ON ^
         -DWITH_ZLIB=ON ^
         -DWITH_BLOSC=ON^
         -DPYTHON_EXECUTABLE="%PYTHON%"

cmake --build . --config %CONFIGURATION% --target install
