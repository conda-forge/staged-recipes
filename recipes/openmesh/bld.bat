
mkdir build
cd build

set CMAKE_CONFIG="Release"
set PYTHON_LIBRARY=%PREFIX%\libs\python%PY_VER:~0,1%%PY_VER:~2,1%.lib

cmake -LAH -G"NMake Makefiles"                               ^
  -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%"                        ^
  -DCMAKE_FIND_ROOT_PATH="%PREFIX%"                          ^
  -DCMAKE_INSTALL_PREFIX="%PREFIX%"                          ^
  -DBUILD_APPS=OFF                                           ^
  -DPYTHON_LIBRARY:FILEPATH="%PYTHON_LIBRARY%"               ^
  -DOPENMESH_PYTHON_VERSION="%PY_VER%"                       ^
  -DOPENMESH_BUILD_PYTHON_UNIT_TESTS=ON ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG%
if errorlevel 1 exit 1
cmake --build . --config %CMAKE_CONFIG% --target INSTALL
if errorlevel 1 exit 1

ctest --output-on-failure
if errorlevel 1 exit 1
