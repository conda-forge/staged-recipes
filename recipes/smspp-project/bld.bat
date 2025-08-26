:: build SMS++
git submodule init
git submodule update

mkdir build
cd build
cmake %CMAKE_ARGS% ^
    -DOpenMP_RUNTIME_MSVC="llvm" ^
    -DBUILD_SHARED_LIBS=ON ^
    ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix %LIBRARY_PREFIX%

copy InvestmentBlock\test\Release\InvestmentBlock_test.exe %LIBRARY_PREFIX%\bin\InvestmentBlock_test.exe
