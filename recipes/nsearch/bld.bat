md build
cd build

cmake -Wno-dev ..
cmake --build . --config Release

copy nsearch\Release\nsearch.exe %PREFIX%\nsearch.exe