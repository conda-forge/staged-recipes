mkdir build
cd build 

cmake -G "MinGW Makefiles" ^
      -D CMAKE_BUILD_TYPE:STRING=Release ^
      -D CMAKE_PREFIX_PATH:FILEPATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:FILEPATH=%LIBRARY_PREFIX% ^
      -D CMAKE_SH="CMAKE_SH-NOTFOUND" ^
      ..

mingw32-make VERBOSE=1
mingw32-make install

cd ..

%PYTHON% setup.py build_ext
%PYTHON% setup.py install
