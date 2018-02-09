mkdir build && cd build

cmake -G"Visual Studio 14 2015 Win64"                   ^
  -DCMAKE_BUILD_TYPE="Release"                          ^
  -DCMAKE_PREFIX_PATH="%PREFIX%"                        ^
  -DCMAKE_INSTALL_PREFIX="%PREFIX%"                     ^
  -DCGAL_LIBRARIES="Library/bin/CGAL-vc140-mt-4.11.dll" ^
  -DPython_ADDITIONAL_VERSIONS=3                        ^
  ..
if errorlevel 1 exit 1

cd cython
"%PYTHON%" setup.py install
if errorlevel 1 exit 1

