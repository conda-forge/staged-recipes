@echo on

if exist build-core rmdir /s /q build-core

cmake -S "%SRC_DIR%" -B build-core -G Ninja ^
  %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL ^
  -DBUILD_SHARED_LIBS=ON ^
  -DBOX3D_SAMPLES=OFF ^
  -DBOX3D_UNIT_TESTS=OFF ^
  -DBOX3D_BENCHMARKS=OFF ^
  -DBOX3D_DOCS=OFF ^
  -DBOX3D_PROFILE=OFF ^
  -DBOX3D_VALIDATE=OFF ^
  -DBOX3D_BUILD_SHADERS=OFF
if errorlevel 1 exit 1

cmake --build build-core --config Release --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

cmake --install build-core --config Release
if errorlevel 1 exit 1
