mkdir build
cd build

cmake -G Ninja ^
      -DCHEMICALFUN_PYTHON_INSTALL_PREFIX:PATH="%PREFIX%" ^
      -DCMAKE_BUILD_TYPE=Release ^
      ..
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
