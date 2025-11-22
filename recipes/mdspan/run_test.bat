@echo on

:: Build the test program
cd tests

cmake -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    .
if errorlevel 1 exit 1

cmake --build .
if errorlevel 1 exit 1

:: Run the test program
test_mdspan.exe
if errorlevel 1 exit 1
