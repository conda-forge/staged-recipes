@REM Copy the downloaded dependencies in meta.yaml to the dirs expected by c4core
@REM NOTE: These dependencies are not vendored by c4core! They are small and specific to c4core.
xcopy /E /I deps\cmake .
xcopy /E /I deps\debugbreak .\src\c4\ext

@REM Configure the build of the library
mkdir build
cd build
cmake -GNinja .. %CMAKE_ARGS% -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON

@REM Build and install the library in $PREFIX
ninja install
