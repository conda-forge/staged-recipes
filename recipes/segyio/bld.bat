cmake -G"%CMAKE_GENERATOR%" ^
      -DBUILD_SHARED_LIBS=ON ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
      -DBUILD_PYTHON=OFF ^
      %SRC_DIR%

if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1

%PYTHON% setup.py build_ext -L %PREFIX%\lib install --prefix %PREFIX%
if errorlevel 1 exit 1
