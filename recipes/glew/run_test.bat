conda env create -f %RECIPE_DIR%\test\test-environment-windows.yml
activate test-environment-windows
md build
cd build
cmake  -G "NMake Makefiles" %RECIPE_DIR%/test -DCMAKE_BUILD_TYPE=Release
nmake
.\main