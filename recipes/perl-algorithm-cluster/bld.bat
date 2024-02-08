perl Makefile.PL INSTALLDIRS=vendor NO_PERLLOCAL=1 NO_PACKLIST=1 MAKE=mingw32-make
IF %ERRORLEVEL% NEQ 0 exit /B 1
dir %LIBRARY_PREFIX% /b /a /s
IF %ERRORLEVEL% NEQ 0 exit /B 1
for /r . %%f in (*Makefile) do perl -i -pe "s|C:\\strawberry\\c|$ENV{LIBRARY_PREFIX}\\mingw-w64|g" %%f
IF %ERRORLEVEL% NEQ 0 exit /B 1
mingw32-make
IF %ERRORLEVEL% NEQ 0 exit /B 1
mingw32-make test
IF %ERRORLEVEL% NEQ 0 exit /B 1
mingw32-make install VERBINST=1
IF %ERRORLEVEL% NEQ 0 exit /B 1
