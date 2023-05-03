setlocal EnableDelayedExpansion

mkdir build
cd build

set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"
set "CL=/MP"

::Configure
cmake ^
    %SRC_DIR% ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DBUILD_MODULE_visp_ar=ON ^
    -DBUILD_MODULE_visp_blob=ON ^
    -DBUILD_MODULE_visp_core=ON ^
    -DBUILD_MODULE_visp_detection=ON ^
    -DBUILD_MODULE_visp_gui=ON ^
    -DBUILD_MODULE_visp_imgproc=ON ^
    -DBUILD_MODULE_visp_io=ON ^
    -DBUILD_MODULE_visp_klt=ON ^
    -DBUILD_MODULE_visp_mbt=ON ^
    -DBUILD_MODULE_visp_me=ON ^
    -DBUILD_MODULE_visp_robot=ON ^
    -DBUILD_MODULE_visp_sensor=ON ^
    -DBUILD_MODULE_visp_tt=ON ^
    -DBUILD_MODULE_visp_tt_mi=ON ^
    -DBUILD_MODULE_visp_vision=ON ^
    -DBUILD_MODULE_visp_visual_features=ON ^
    -DBUILD_MODULE_visp_vs=ON ^
    -DUSE_OPENMP=ON ^
    -DUSE_PTHREAD=ON ^
    -DWITH_LAPACK=OFF ^
    -DBUILD_TESTS=ON
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%" --verbose
if errorlevel 1 exit 1

:: test
ctest --parallel "%CPU_COUNT%" --verbose
if errorlevel 1 exit 1

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --verbose --target install
if errorlevel 1 exit 1