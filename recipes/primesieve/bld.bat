nmake /f Makefile.msvc
if errorlevel 1 exit 1

nmake /f Makefile.msvc check
if errorlevel 1 exit 1

cp include\primesieve.h %LIBRARY_INC%
if errorlevel 1 exit 1

cp include\primesieve.hpp %LIBRARY_INC%
if errorlevel 1 exit 1

cp primesieve.lib %LIBRARY_LIB%
if errorlevel 1 exit 1

cp primesieve.exe %LIBRARY_BIN%
if errorlevel 1 exit 1
