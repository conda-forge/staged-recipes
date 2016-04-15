:: Configure step.
cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      - DCMAKE_INSTALL_PREFIX:%LIBRARY_PREFIX% %SRC_DIR% ^
      %SRC_DIR%
if errorlevel 1 exit 1

:: Build step.
cmake --build %SRC_DIR% --target INSTALL --config Release
if errorlevel 1 exit 1

:: cmake Test.
ctest
if errorlevel 1 exit 1

:: Some OSS libraries are happier if z.lib exists, even though it's not typical on Windows.
copy %SRC_DIR%\zlib.lib %LIBRARY_LIB%\z.lib || exit 1

:: Qt in particular goes looking for this one (as of 4.8.7).
copy %SRC_DIR%\zlib.lib %LIBRARY_LIB%\zdll.lib || exit 1

:: Copy license file to the source directory so conda-build can find it.
copy %RECIPE_DIR%\license.txt %SRC_DIR%\license.txt || exit 1
