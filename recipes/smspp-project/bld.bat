::stopt

git clone https://gitlab.com/stochastic-control/StOpt

cd StOpt

mkdir build
cd build

cmake %CMAKE_ARGS% ^
    -DCMAKE_CXX_FLAGS="/UBOOST_ALL_DYN_LINK" ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" ^
    -DBUILD_PYTHON=OFF ^
    -DBUILD_TEST=OFF ^
    ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --prefix "%LIBRARY_PREFIX%"

cd ..\..

:: build SMS++
git submodule init
git submodule update

set "CFLAGS=%CFLAGS% /I%LIBRARY_PREFIX%\include"
set "CXXFLAGS=%CXXFLAGS% /I%LIBRARY_PREFIX%\include"
set "LDFLAGS=%LDFLAGS% /LIBPATH:%LIBRARY_PREFIX%\lib"

mkdir build
cd build
cmake %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" ^
    ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix "$PREFIX"
