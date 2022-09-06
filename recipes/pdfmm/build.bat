
REM configure cmake
cmake -B build -prefix=%PREFIX -DCMAKE_BUILD_TYPE=Release -A x64 -DARCH=Win64

REM build
make --build build -prefix=%PREFIX --config Release --parallel

REM install
cmake --install build --prefix=${PREFIX}
