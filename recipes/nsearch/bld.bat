md build
cd build

cmake -G "Visual Studio 15 2017" -A x64 -Wno-dev ..
cmake --build . --config Release

copy nsearch\Release\nsearch.exe %PREFIX%\nsearch.exe