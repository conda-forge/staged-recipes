mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DOMPL_BUILD_DEMOS=OFF ^
    -DOMPL_BUILD_TESTS=OFF ^
    -DOMPL_BUILD_PYTESTS=OFF ^
    -DOMPL_REGISTRATION=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
