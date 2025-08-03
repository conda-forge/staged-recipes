cmake %CMAKE_ARGS% -G "Ninja"                                ^
       -DCMAKE_C_COMPILER=clang-cl              ^
       -DCMAKE_CXX_COMPILER=clang-cl            ^
       -DCMAKE_BUILD_TYPE=Release               ^
       -DBLIS_CONFIG_FAMILY=amdzen              ^
       -DCOMPLEX_RETURN=gnu                     ^
       -DBUILD_STATIC_LIBS=OFF                  ^
       -DENABLE_THREADING=openmp                ^
       -DOpenMP_ROOT=%LIBRARY_LIB%              ^
       -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%  ^
       -S %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

