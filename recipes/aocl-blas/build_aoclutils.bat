cmake %CMAKE_ARGS% -G "Ninja"                                ^
       -DCMAKE_C_COMPILER=clang-cl              ^
       -DCMAKE_CXX_COMPILER=clang-cl            ^
       -DCMAKE_BUILD_TYPE=Release               ^
       -DAU_BUILD_STATIC_LIBS=OFF               ^
       -S aoclutils                             ^
       -B buildaoclutils
if errorlevel 1 exit 1

cmake --build buildaoclutils --parallel %CPU_COUNT% --target install
if errorlevel 1 exit 1

