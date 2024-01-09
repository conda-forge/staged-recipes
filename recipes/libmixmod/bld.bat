
cmake -LAH -G "Ninja" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DMIXMOD_BUILD_EXAMPLES=ON ^
    -DCMAKE_UNITY_BUILD=ON ^
    -DBUILD_SHARED_LIBS=OFF ^
    .
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

ctest --output-on-failure --timeout 1000
if errorlevel 1 exit 1
