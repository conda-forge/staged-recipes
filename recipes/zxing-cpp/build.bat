cmake -GNinja -B build %CMAKE_ARGS% ^
  -DBUILD_SHARED_LIBS=ON ^
  -DZXING_READERS=ON ^
  -DZXING_WRITERS=OLD ^
  -DZXING_C_API=OFF ^
  -DZXING_EXPERIMENTAL_API=OFF ^
  -DZXING_EXAMPLES=OFF ^
  -DZXING_EXAMPLES_QT=OFF ^
  -DZXING_BLACKBOX_TESTS=OFF ^
  -DZXING_UNIT_TESTS=OFF
if errorlevel 1 exit 1

cmake --build build --config Release
if errorlevel 1 exit 1

cmake --install build --config Release
if errorlevel 1 exit 1
