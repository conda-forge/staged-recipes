REM Avoid in-source build. The file fftn.c expects to reload itself using
REM __FILE__ which breaks on windows if the value is relative. By setting
REM a build directory *outside* the source directory, we avoid the issue.
REM https://stackoverflow.com/q/53574345/1005215

cmake -S%SRC_DIR% -B%SRC_DIR%.build -GNinja ^
   -DCMAKE_BUILD_TYPE=Release ^
   -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

cmake --build %SRC_DIR%.build -- install
if errorlevel 1 exit 1
