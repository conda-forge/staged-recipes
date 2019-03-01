echo on

cd test

mkdir build
cd build

cmake .. ^
    -GNinja ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_VERBOSE_MAKEFILE=ON || goto :error

ninja || goto :error

test.exe || goto :error

exit /B 0


:error
echo ERROR!
echo Command exit status: %ERRORLEVEL%
