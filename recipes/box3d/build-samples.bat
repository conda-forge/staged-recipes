@echo on

if exist build-samples rmdir /s /q build-samples

cmake -S "%SRC_DIR%" -B build-samples -G Ninja ^
  %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL ^
  -DBUILD_SHARED_LIBS=ON ^
  -DBOX3D_SAMPLES=ON ^
  -DBOX3D_UNIT_TESTS=OFF ^
  -DBOX3D_BENCHMARKS=OFF ^
  -DBOX3D_DOCS=OFF ^
  -DBOX3D_PROFILE=OFF ^
  -DBOX3D_VALIDATE=OFF ^
  -DBOX3D_BUILD_SHADERS=OFF
if errorlevel 1 exit 1

cmake --build build-samples --config Release --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

cmake --install build-samples --config Release
if errorlevel 1 exit 1

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
copy /Y build-samples\bin\samples.exe "%LIBRARY_BIN%\box3d-samples.exe"
if errorlevel 1 exit 1
