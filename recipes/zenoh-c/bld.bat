mkdir build
cd build

cmake -GNinja %CMAKE_ARGS% ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DBUILD_SHARED_LIBS:BOOL=ON ^
      -DZENOHC_INSTALL_STATIC_LIBRARY:BOOL=OFF ^
      -DZENOHC_LIB_STATIC:BOOL=OFF ^
      -DZENOHC_CARGO_FLAGS:STRING="--locked" ^
      %SRC_DIR%
if %errorlevel% NEQ 0 exit /b %errorlevel%

cmake --build .
if %errorlevel% NEQ 0 exit /b %errorlevel%

cmake --install .
if %errorlevel% NEQ 0 exit /b %errorlevel%

cargo-bundle-licenses --format yaml --output %SRC_DIR%\THIRDPARTY.yml
if %errorlevel% NEQ 0 exit /b %errorlevel%

cmake --build . --target tests --config Release
if %errorlevel% NEQ 0 exit /b %errorlevel%

ctest -C Release --output-on-failure -E "(unit_z_api_alignment_test|build_z_build_static)"
if %errorlevel% NEQ 0 exit /b %errorlevel%
