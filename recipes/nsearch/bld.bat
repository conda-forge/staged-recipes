md build
cd build

cmake -G "Visual Studio 16 2019" -A x64 -Wno-dev ..
cmake --build . --config Release

copy nsearch\Release\nsearch.exe %PREFIX%\nsearch.exe