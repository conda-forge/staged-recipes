mkdir build
cd build 

cmake -D CMAKE_BUILD_TYPE:STRING=Release ^
      -D CMAKE_PREFIX_PATH:FILEPATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:FILEPATH=%LIBRARY_PREFIX% ^
      ..

make install

cd ..

%PYTHON% setup.py build_ext
%PYTHON% setup.py install