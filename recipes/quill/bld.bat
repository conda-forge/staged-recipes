cmake -G "NMake Makefiles" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DQUILL_BUILD_TESTS=ON ^
  .
if errorlevel 1 exit 1

cmake --build . --target TEST_ArithmeticTypesLogging
if errorlevel 1 exit 1

ctest -R arithmetic_types_logging
if errorlevel 1 exit 1

cmake --install .
if errorlevel 1 exit 1
