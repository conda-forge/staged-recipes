setlocal EnableDelayedExpansion

:: Make a build folder and change to it.
mkdir build
cd build

:: Configure using the CMakeFiles
cmake -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DSKIP_DOCS=TRUE ^
    -DSKIP_CUDA_LIB=TRUE ^
    %SRC_DIR%
if %ERRORLEVEL% neq 0 exit 1

cmake --build . --target install --verbose 
if %ERRORLEVEL% neq 0 exit 1
