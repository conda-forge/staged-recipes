cmake %CMAKE_ARGS% -S . -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release
if %ERRORLEVEL% neq 0 exit 1

cmake --build build --config Release --target install
if %ERRORLEVEL% neq 0 exit 1
