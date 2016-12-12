md build
cd build
cmake  -G "NMake Makefiles" %RECIPE_DIR%/test -DCMAKE_BUILD_TYPE=Release
nmake
.\main