cmake %CMAKE_ARGS% -G "Ninja"                                ^
       -DCMAKE_C_COMPILER=clang-cl              ^
       -DCMAKE_CXX_COMPILER=clang-cl            ^
       -DCMAKE_BUILD_TYPE=Release               ^
       -DENABLE_AMD_FLAGS=ON                    ^
       -DENABLE_AOCL_BLAS=ON                    ^
       -DOpenMP_ROOT=%LIBRARY_LIB%              ^
       -S aocllapack                            ^
       -B buildaocllapack
if errorlevel 1 exit 1

cmake --build buildaocllapack --target install
if errorlevel 1 exit 1

