cd win32

nmake /f Makefile.win32 all install INSTDIR=$PREFIX
if errorlevel 1 exit 1
