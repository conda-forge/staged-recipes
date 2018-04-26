
copy %RECIPE_DIR%\CMakeLists.txt %SRC_DIR%
copy %RECIPE_DIR%\dsdp.def %SRC_DIR%
cmake %SRC_DIR% -G "NMake Makefiles" ^
                    -DCMAKE_BUILD_TYPE=Release ^
                    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
                    -DBUILD_SHARED_LIBS=ON
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
