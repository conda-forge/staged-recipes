perl Makefile.PL INSTALLDIRS=vendor NO_PERLLOCAL=1 NO_PACKLIST=1 MAKE=make
IF %ERRORLEVEL% NEQ 0 exit /B 1
make
IF %ERRORLEVEL% NEQ 0 exit /B 1
make test
:: IF %ERRORLEVEL% NEQ 0 exit /B 1
make install VERBINST=1
IF %ERRORLEVEL% NEQ 0 exit /B 1
