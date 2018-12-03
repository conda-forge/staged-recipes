rem TODO
REM set TMP="%LOCALAPPDATA%\Temp"
REM set TEMP="%LOCALAPPDATA%\Temp"
REM set TMPDIR="%LOCALAPPDATA%\Temp"
IF "%ARCH%" == "64" (
set GCC_ARCH=x86_64-w64-mingw32
set EXTRA_FLAGS=-DMS_WIN64
) else (
set GCC_ARCH=i686-w64-mingw32
)
bash -lc "ln -s ${LOCALAPPDATA}/Temp /tmp"
bash -lc "./configure --prefix=$PREFIX --enable-shared --enable-python --disable-zlib --disable-external-lapack --disable-external-blas"
bash -lc "make -j2"
bash -lc "make install"
bash -lc "make -C python pip"
%PYTHON% -m pip install python 



