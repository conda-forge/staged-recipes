:: build SMS++
git submodule init
git submodule update

mkdir build
cd build
cmake %CMAKE_ARGS% .. -DBLAS_LIBRARIES="%LIBRARY_PREFIX%/lib/mkl_intel_ilp64.lib;%LIBRARY_PREFIX%/lib/mkl_sequential.lib;%LIBRARY_PREFIX%/lib/mkl_core.lib"
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix "$PREFIX"

copy InvestmentBlock\test\Release\InvestmentBlock_test.exe %PREFIX%\bin\InvestmentBlock_test.exe