cmake %CMAKE_ARGS% -G "Ninja"                           ^
       -DCMAKE_C_COMPILER=clang-cl                      ^
       -DCMAKE_CXX_COMPILER=clang-cl                    ^
       -DCMAKE_BUILD_TYPE=Release                       ^
       -DBLIS_CONFIG_FAMILY=amdzen                      ^
       -DCOMPLEX_RETURN=gnu                             ^
       -DBUILD_STATIC_LIBS=OFF                          ^
       -DENABLE_THREADING=openmp                        ^
       -DOpenMP_ROOT=%LIBRARY_LIB%                      ^
       -S aoclblas                                      ^
       -B buildaoclblas
if errorlevel 1 exit 1

cmake --build buildaoclblas --parallel %CPU_COUNT% --target install
if errorlevel 1 exit 1

move %LIBRARY_LIB%\AOCL-LibBlis-Win-MT-dll.dll %LIBRARY_BIN%\AOCL-LibBlis-Win-MT-dll.dll 
if errorlevel 1 exit 1
