cmake %CMAKE_ARGS% -G "Ninja"                                ^
       -DCMAKE_C_COMPILER=clang-cl              ^
       -DCMAKE_CXX_COMPILER=clang-cl            ^
       -DCMAKE_BUILD_TYPE=Release               ^
       -DAU_BUILD_STATIC_LIBS=OFF               ^
       -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%  ^
       -S aoclutils                             ^
       -B buildaoclutils
if errorlevel 1 exit 1

cmake --build buildaoclutils --target install
if errorlevel 1 exit 1

