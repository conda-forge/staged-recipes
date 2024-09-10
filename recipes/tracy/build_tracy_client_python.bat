rm -rf build

:: Python module from previous build can be copied in the source directory.
:: We must remove them to avoid binary conflict.
rm -rf python/tracy_client/*.so* python/build python/tracy_client.egg-info

mkdir build
cd build

cmake .. ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    -GNinja ^
    -DTRACY_CLIENT_PYTHON=ON ^
    -DPython_EXECUTABLE="%PYTHON%" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%"

:: build
cmake --build . --parallel %CPU_COUNT%

:: install
cmake --build . --target install

:: this will also install headers again
:: but without the Tracy(Targets*|Config).cmake files
cd ../python
%PYTHON% -m pip install . --no-deps --ignore-installed
