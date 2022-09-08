
REM configure cmake
cmake -B build -prefix=%PREFIX -DCMAKE_BUILD_TYPE=Release -A x64 -DARCH=Win64 -DCMAKE_CXX_STANDARD=17

REM build
make --build build -prefix=%PREFIX --config Release

REM install
cmake --install build --prefix=${PREFIX}
