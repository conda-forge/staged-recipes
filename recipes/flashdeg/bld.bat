@echo on

cmake -S "%SRC_DIR%" -B build -G Ninja %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DFLASHDEG_BUILD_TESTS=OFF ^
  -DFLASHDEG_ENABLE_DEV_OPTIONS=OFF ^
  -DFLASHDEG_ALLOW_NO_DEPS_BUILD=OFF ^
  -DFLASHDEG_USE_EIGEN=ON ^
  -DFLASHDEG_USE_BOOST_MATH=ON ^
  -DFLASHDEG_USE_BLAS=ON ^
  -DFLASHDEG_USE_SCIPY_LBFGSB=ON
if errorlevel 1 exit /b 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1

cmake --install build --prefix "%LIBRARY_PREFIX%"
if errorlevel 1 exit /b 1
