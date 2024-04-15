mkdir build
cd build

set EXTRA_CMAKE_ARGS=""
if NOT "%cuda_compiler_version%"=="None" (
    set EXTRA_CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=all -DCARLSIM_NO_CUDA=OFF"
) else (
    set EXTRA_CMAKE_ARGS="-DCARLSIM_NO_CUDA=ON"
)

set CL=/DWIN64=1 %CL%

cmake ^
    -G "Ninja" ^
    -DCARLSIM_SAMPLES=OFF ^
    -DCARLSIM_BENCHMARKS=OFF ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_CXX_FLAGS=-DNOMINMAX ^
    -DCMAKE_CUDA_FLAGS=--use-local-env ^
    %EXTRA_CMAKE_ARGS% ^
    %SRC_DIR%
if errorlevel 1 exit 1

xcopy %RECIPE_DIR%\cuda-samples\* %SRC_DIR%\carlsim\kernel\inc\ /s /i

:: Build.
cmake --build . --config Release -- -j1
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
