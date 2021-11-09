
cd wincon

nmake -f Makefile.vc WIDE=Y DLL=Y UTF8=Y
if errorlevel 1 exit 1

REM install header files
mkdir %LIBRARY_PREFIX%\include\
cp %SRC_DIR%\curses.h %LIBRARY_PREFIX%\include\
cp %SRC_DIR%\curspriv.h %LIBRARY_PREFIX%\include\
cp %SRC_DIR%\panel.h %LIBRARY_PREFIX%\include\

REM install dll
mkdir %LIBRARY_PREFIX%\bin\
cp pdcurses.dll %LIBRARY_PREFIX%\bin\

REM install lib
mkdir %LIBRARY_PREFIX%\lib\
cp pdcurses.lib %LIBRARY_PREFIX%\lib\
