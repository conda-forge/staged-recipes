cd %SRC_DIR%\test
conda env create -f .\test-environment.yml
activate test-xtensor
cmake -G "NMake Makefiles" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -D CMAKE_BUILD_TYPE=Release .
nmake
.\test_xtensor
