set CMAKE_GENERATOR=Ninja
set CMAKE_BUILD_PARALLEL_LEVEL=%CPU_COUNT%

set SKBUILD_CMAKE_ARGS=-DLATTICE_DSP_USE_OPENMP=OFF

echo PYTHON=%PYTHON%
echo CC=%CC%
echo CXX=%CXX%
echo CMAKE_GENERATOR=%CMAKE_GENERATOR%
echo SKBUILD_CMAKE_ARGS=%SKBUILD_CMAKE_ARGS%

where cmake
cmake --version
where ninja
ninja --version

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
