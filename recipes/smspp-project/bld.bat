:: build SMS++

mkdir build
cd build
cmake %CMAKE_ARGS% ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix "$PREFIX"

copy InvestmentBlock\test\Release\InvestmentBlock_test.exe %PREFIX%\bin\InvestmentBlock_test.exe