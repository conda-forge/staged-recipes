mkdir build
cd build

set "CXXFLAGS="

cmake ^
    -G "Ninja" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DPYTHON_LIBRARY="%PREFIX%\libs\python%CONDA_PY%.lib" ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
