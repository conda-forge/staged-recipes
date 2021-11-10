
cd wincon

nmake -f Makefile.vc WIDE=Y DLL=Y UTF8=Y
if errorlevel 1 exit 1

REM install header files
mkdir %LIBRARY_PREFIX%\include\
copy %SRC_DIR%\curses.h %LIBRARY_PREFIX%\include\
copy %SRC_DIR%\curspriv.h %LIBRARY_PREFIX%\include\
copy %SRC_DIR%\panel.h %LIBRARY_PREFIX%\include\

REM install dll
mkdir %LIBRARY_PREFIX%\bin\
copy pdcurses.dll %LIBRARY_PREFIX%\bin\

REM install lib
mkdir %LIBRARY_PREFIX%\lib\
copy pdcurses.lib %LIBRARY_PREFIX%\lib\
