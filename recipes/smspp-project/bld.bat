::stopt

git clone https://gitlab.com/stochastic-control/StOpt

cd StOpt

mkdir build
cd build

cmake %CMAKE_ARGS% ^
    -DBUILD_PYTHON=OFF ^
    -DBUILD_TEST=OFF ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" ^
    ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --prefix "%LIBRARY_PREFIX%"

cd ..\..

:: build SMS++
git submodule init
git submodule update

mkdir build
cd build
cmake %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" ^
    ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix "$PREFIX"
