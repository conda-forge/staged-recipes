mkdir build && cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles" ^
  -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%" ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DPython_ADDITIONAL_VERSIONS=${PY_VER} ^
  -DPYTHON_EXECUTABLE="%PYTHON%" ^
  -DWITH_GUDHI_PYTHON=OFF ^
  ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target INSTALL
if errorlevel 1 exit 1

cmake -DWITH_GUDHI_PYTHON=ON .
if errorlevel 1 exit 1

cd cython
python setup.py install
if errorlevel 1 exit 1

