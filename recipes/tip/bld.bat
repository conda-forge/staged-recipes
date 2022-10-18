setlocal EnableDelayedExpansion

mkdir build
cd build

:: Hardcoded USER_VERSION is bad. Can't get previously un-defined
:: env var that is defined in build.script_env to pass through. 
:: How to do this?
:: USER_VERSION is used to hardcode version in built executables.
:: It is typically unnecessary because CMake configure-time uses
:: git ops to discover tag or commit SHA, both of which are not 
:: available since packages are built from tarballs.
cmake .. -GNinja -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCONDA_PREFIX:PATH="%CONDA_PREFIX%" ^
    -DUSER_VERSION:STRING=v1.0.0

if errorlevel 1 exit /b 1

ninja install -j8
if errorlevel 1 exit /b 1