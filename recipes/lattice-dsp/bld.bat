@echo on

set CMAKE_GENERATOR=Ninja
set CMAKE_GENERATOR_PLATFORM=
set CMAKE_GENERATOR_TOOLSET=
set CMAKE_ARGS=

set CMAKE_BUILD_PARALLEL_LEVEL=%CPU_COUNT%

echo PYTHON=%PYTHON%
echo CC=%CC%
echo CXX=%CXX%
echo CMAKE_GENERATOR=%CMAKE_GENERATOR%
echo CMAKE_GENERATOR_PLATFORM=%CMAKE_GENERATOR_PLATFORM%
echo CMAKE_GENERATOR_TOOLSET=%CMAKE_GENERATOR_TOOLSET%
echo CMAKE_ARGS=%CMAKE_ARGS%

where cmake
cmake --version
where ninja
ninja --version

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
