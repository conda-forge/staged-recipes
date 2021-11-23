copy %RECIPE_DIR%\build.sh build.sh

set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
bash build.sh
if errorlevel 1 exit 1
exit 0
