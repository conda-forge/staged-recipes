@echo on

mkdir build
cd build

cmake -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    ..
if %ERRORLEVEL% neq 0 exit 1

cmake --build .
if %ERRORLEVEL% neq 0 exit 1

cmake --install . --prefix %PREFIX%\Library
if %ERRORLEVEL% neq 0 exit 1
