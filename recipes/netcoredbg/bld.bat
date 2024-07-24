cmake -S . -G Ninja -B build ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_VERBOSE_MAKEFILE=ON ^
    -Wno-dev ^
    -DBUILD_TESTING=OFF ^
    -DDOTNET_DIR=%DOTNET_ROOT% ^
    %CMAKE_ARGS% || goto :error

cmake --build build || goto :error
cmake --install build || goto :error

goto :EOF

:error
echo Failed with #%errorlevel%.
exit 1
