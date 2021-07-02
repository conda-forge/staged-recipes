@REM Build and execute C++ test application using yaml-cpp4rkt
cd test/app
cmake -S . -B build -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%
cmake --build build --config Release
build/app.exe
