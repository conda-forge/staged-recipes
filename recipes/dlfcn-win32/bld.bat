mkdir build
cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles"              ^
  -DCMAKE_BUILD_TYPE=%CMAKE_CONFIG%         ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%      ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%   ^
  %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1
