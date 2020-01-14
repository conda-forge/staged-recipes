REM set TMP="%LOCALAPPDATA%\Temp"
REM set TEMP="%LOCALAPPDATA%\Temp"
REM set TMPDIR="%LOCALAPPDATA%\Temp"
if "%ARCH%" == "64" (
set GCC_ARCH=x86_64-w64-mingw32
set EXTRA_FLAGS="-DMS_WIN64 -I/mingw-w64/%GCC_ARCH%/include/"
) else (
set GCC_ARCH=i686-w64-mingw32
set EXTRA_FLAGS="-I/mingw-w64/%GCC_ARCH%/include/"
)
bash -lc "mkdir -p /tmp; ln -s ${LOCALAPPDATA}/Temp /tmp"
bash -lc "echo $CYGWIN_PREFIX"
bash -lc "export LDFLAGS=-L`cygpath -u $LIBRARY_LIB`; echo $LDFLAGS; ls -l `cygpath -u $LIBRARY_LIB`"
bash -lc "cd src; export LDFLAGS=-L`cygpath -u $LIBRARY_LIB`; export PYTHON=`which python`; ./configure --disable-openmp --enable-python --build=$GCC_ARCH --host=$GCC_ARCH --target=$GCC_ARCH --prefix=$CYGWIN_PREFIX CFLAGS=$EXTRA_FLAGS"
bash -lc "cd src; make"
bash -lc "cd src; make install"