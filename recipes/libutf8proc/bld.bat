mkdir build
cd build

set BUILD_TYPE="Release"

cmake .. -G "%CMAKE_GENERATOR%" ^
  -DBUILD_SHARED_LIBS=ON ^
  -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"
if errorlevel 1 exit \b 1

cmake --build . --config %BUILD_TYPE% --target install
if errorlevel 1 exit \b 1

cmake .. -G "%CMAKE_GENERATOR%" ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"
if errorlevel 1 exit \b 1

cmake --build . --config %BUILD_TYPE% --target install
if errorlevel 1 exit \b 1
