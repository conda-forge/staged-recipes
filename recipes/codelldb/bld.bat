cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error

cmake -S . -B build ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_VERBOSE_MAKEFILE=ON ^
    -Wno-dev ^
    -DBUILD_TESTING=OFF ^
    -DLLDB_PACKAGE=%LIBRARY_PREFIX% ^
    %CMAKE_ARGS% || goto :error

cmake --build build -j%CPU_COUNT% || goto :error

mkdir %LIBRARY_PREFIX%\bin || goto :error
cp .\build\target\*\release\codelldb.exe %LIBRARY_PREFIX%\bin || goto :error
cp .\build\adapter\libcodelldb.dll %LIBRARY_PREFIX%\bin || goto :error
mkdir %LIBRARY_PREFIX%\lib || goto :error
cp .\build\adapter\libcodelldb.lib %LIBRARY_PREFIX%\lib || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
