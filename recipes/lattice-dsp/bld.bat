set CMAKE_GENERATOR=Ninja
set CMAKE_BUILD_PARALLEL_LEVEL=%CPU_COUNT%

echo PYTHON=%PYTHON%
echo CC=%CC%
echo CXX=%CXX%
where cmake
cmake --version
where ninja
ninja --version

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
