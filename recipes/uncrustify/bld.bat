cmake -S . -G Ninja -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    %CMAKE_ARGS% || goto :error

cmake --build build -j%CPU_COUNT% || goto :error
cmake --install build || goto :error

mkdir %PREFIX%\share\doc\%PKG_NAME% || goto :error
xcopy /s /e /t documentation\* %PREFIX%\share\doc\%PKG_NAME% || goto :error

goto :EOF

:error
echo Failed with #%errorlevel%.
exit 1
