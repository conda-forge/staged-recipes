REM https://discourse.cmake.org/t/how-to-find-openmp-with-clang-on-macos/8860
set "CMAKE_EXTRA=-DOpenMP_ROOT=%LIBRARY_LIB%"

cmake -G "Ninja"                    ^
       -DCMAKE_C_COMPILER=clang-cl  ^
       -DCMAKE_Fortran_COMPILER=flang ^
       -DCMAKE_BUILD_TYPE=Release   ^
       -DBLIS_CONFIG_FAMILY=amdzen  ^
       -DBUILD_STATIC_LIBS=OFF      ^
       -DENABLE_THREADING=openmp    ^
       -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
       !CMAKE_EXTRA!                ^
       %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

