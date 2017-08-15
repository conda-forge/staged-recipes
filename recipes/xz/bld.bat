if "%ARCH%" == "64" (
   set ARCH=x64
) else (
   set ARCH=Win32
)

cd Windows

call devenv /Upgrade xz_win.sln
msbuild xz_win.sln /p:Configuration="Release" /p:Platform="%ARCH%" /verbosity:normal
if errorlevel 1 exit 1

COPY Release\%ARCH%\liblzma_dll\liblzma.dll %LIBRARY_BIN%\
COPY Release\%ARCH%\liblzma_dll\liblzma.lib %LIBRARY_LIB%\
COPY Release\%ARCH%\liblzma\liblzma.lib %LIBRARY_LIB%\liblzma_static.lib

cd %SRC_DIR%

MOVE src\liblzma\api\lzma %LIBRARY_INC%\
COPY src\liblzma\api\lzma.h %LIBRARY_INC%\
