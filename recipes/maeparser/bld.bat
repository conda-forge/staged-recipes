mkdir build
cd build
cmake.exe .. -G "NMake Makefiles JOM" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    || goto :error

jom -j %NUMBER_OF_PROCESSORS% || goto :error
jom -j %NUMBER_OF_PROCESSORS% install || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%