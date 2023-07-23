mkdir build
cd build

cmake -G "Ninja" ^
       -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
       ..

ninja install
