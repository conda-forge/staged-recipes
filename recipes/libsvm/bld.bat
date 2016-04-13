REM Clean First
nmake /f Makefile.win clean all

REM Build step
nmake /f Makefile.win lib
if errorlevel 1 exit 1

REM Install step
copy libsvm.dll %LIBRARY_LIB%\
if errorlevel 1 exit 1
copy svm.h %LIBRARY_INC%\
if errorlevel 1 exit 1
