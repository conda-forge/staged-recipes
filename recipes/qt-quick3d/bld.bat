
cmake -LAH -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_UNITY_BUILD=ON -DCMAKE_UNITY_BUILD_BATCH_SIZE=32 ^
    -DCMAKE_MESSAGE_LOG_LEVEL=STATUS ^
    -DFEATURE_quick3d_assimp=OFF ^
    -B build .
if errorlevel 1 exit 1

cmake --build build --target install --config Release
if errorlevel 1 exit 1

:: we set INSTALL_BINDIR != /bin to avoid clobbering qt5 exes but still dlls in /bin
xcopy /y /s %LIBRARY_PREFIX%\lib\qt6\bin\*.dll %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1
