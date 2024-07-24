cmake -S . -B build -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_VERBOSE_MAKEFILE=ON ^
    -Wno-dev ^
    -DBUILD_TESTING=OFF ^
    %CMAKE_ARGS%
cmake --build build --target Luau.LanguageServer.CLI --config Release -j%CPU_COUNT%

mkdir %LIBRARY_PREFIX%\bin
copy build\%PKG_NAME% %LIBRARY_PREFIX%\bin
