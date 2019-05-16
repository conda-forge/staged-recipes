set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
FOR /F "delims=" %%i in ('cygpath.exe -u "%PREFIX%"') DO set "PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%BUILD_PREFIX%"') DO set "BUILD_PREFIX=%%i"

bash -lc "autoreconf --install --symlink -I m4"
bash -lc "configure --prefix=$PREFIX"

bash -lc "make"
bash -lc "make install"
