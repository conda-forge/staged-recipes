@echo on

cmake -LAH -G "Ninja" ^
    %CMAKE_ARGS% ^
    -DWITH_3RD_PARTY_LIBS=OFF ^
    -B build .
if errorlevel 1 exit 1

cmake --build build --target install --config Release
if errorlevel 1 exit 1

