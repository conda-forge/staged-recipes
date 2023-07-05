
git clone --depth 1 -b V9_11_0 https://git.salome-platform.org/gitpub/tools/configuration.git ${RECIPE_DIR}/configuration

cmake -LAH -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_C_FLAGS="-DH5_USE_110_API" ^
    -DCMAKE_CXX_FLAGS="-DH5_USE_110_API" ^
    -DCMAKE_Fortran_COMPILER=0 ^
    -DPYTHON_EXECUTABLE="%PREFIX%"/python.exe ^
    -DMEDFILE_BUILD_TESTS=OFF ^
    -DMEDFILE_INSTALL_DOC=OFF ^
    -DMEDFILE_BUILD_PYTHON=ON ^
    -DCONFIGURATION_ROOT_DIR=%RECIPE_DIR%/configuration ^
    -B build .
if errorlevel 1 exit 1

cmake --build build --target install --config Release
if errorlevel 1 exit 1

del %LIBRARY_PREFIX%\bin\*mdump*
xcopy /y /s /f %LIBRARY_PREFIX%\lib\*.dll %LIBRARY_PREFIX%\bin
mkdir %PREFIX%\Lib\site-packages\med
xcopy /y /s /f %LIBRARY_PREFIX%\lib\python%PY_VER%\site-packages\med\* %PREFIX%\Lib\site-packages\med
xcopy /y /s /f %LIBRARY_PREFIX%\lib\*.dll %PREFIX%\Lib\site-packages\med
