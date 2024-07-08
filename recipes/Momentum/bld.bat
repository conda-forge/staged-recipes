@echo on

cmake %SRC_DIR% ^
  -B build ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DMOMENTUM_USE_SYSTEM_RERUN_CPP_SDK=ON ^
  -DMOMENTUM_BUILD_TESTING=OFF ^
  -DMOMENTUM_BUILD_EXAMPLES=OFF ^
  -DMOMENTUM_BUILD_PYMOMENTUM=OFF ^
  -DMOMENTUM_BUILD_WITH_EZC3D=OFF ^
  -DMOMENTUM_BUILD_WITH_OPENFBX=OFF
if errorlevel 1 exit 1

cmake --build build --parallel --config Release
if errorlevel 1 exit 1

cmake --build build --parallel --config Release --target install
if errorlevel 1 exit 1
