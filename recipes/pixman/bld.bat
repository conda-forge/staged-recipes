:: SSSE3 is giving errors when compiling with MSVC 9
if %PY_VER%==2.7 (
    set SSSE3_FLAG=off
) else (
    set SSSE3_FLAG=on
)

:: MMX is giving errors when linking cairo in 64 bit systems
if %ARCH%==64 (
    set MMX_FLAG=off
) else (
    set MMX_FLAG=on
)

:: Comnpiling
make -f Makefile.win32 SSSE3=%SSSE3_FLAG% MMX=%MMX_FLAG%

:: Installing
mkdir %LIBRARY_INC%\pixman
move pixman\pixman.h %LIBRARY_INC%\pixman
move pixman\pixman-version.h %LIBRARY_INC%\pixman

move pixman\release\pixman-1.lib %LIBRARY_LIB%
