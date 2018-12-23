@echo ON
setlocal enabledelayedexpansion

make install PREFIX=%LIBRARY_PREFIX%
cp %RECIPE_DIR%\lcov.bat %LIBRARY_BIN%
