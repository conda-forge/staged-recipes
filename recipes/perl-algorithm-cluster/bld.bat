perl Makefile.PL INSTALLDIRS=vendor NO_PERLLOCAL=1 NO_PACKLIST=1 MAKE=mingw32-make
IF %ERRORLEVEL% NEQ 0 exit /B 1
mingw32-make
IF %ERRORLEVEL% NEQ 0 exit /B 1
mingw32-make test
IF %ERRORLEVEL% NEQ 0 exit /B 1
mingw32-make install VERBINST=1
IF %ERRORLEVEL% NEQ 0 exit /B 1
