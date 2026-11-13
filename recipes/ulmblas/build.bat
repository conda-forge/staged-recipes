:: conda-forge, Windows: the build of build.sh with the MinGW-w64 (UCRT)
:: compilers and the MSYS2 tools of the build environment
bash "%RECIPE_DIR%\build.sh"
if errorlevel 1 exit 1
