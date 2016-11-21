REM Build step
nmake -f makefile.msc
if errorlevel 1 exit 1

REM Install step
copy libbz2.lib %LIBRARY_LIB%\libbz2_static.lib
REM Some packages expect 'bzip2.lib', so make another copy
copy libbz2.lib %LIBRARY_LIB%\bzip2_static.lib
copy bzlib.h %LIBRARY_INC%\

cl /O2 /Ibzlib.h /Ibzlib_private.h /D_USRDLL /D_WINDLL blocksort.c bzlib.c compress.c crctable.c decompress.c huffman.c randtable.c /LD /Felibbz2.dll /link /DEF:libbz2.def

copy libbz2.lib %LIBRARY_LIB%\
REM Some packages expect 'bzip2.lib', so make another copy
copy libbz2.lib %LIBRARY_LIB%\bzip2.lib
copy libbz2.dll %LIBRARY_BIN%\
copy libbz2.dll %LIBRARY_BIN%\bzip2.dll
