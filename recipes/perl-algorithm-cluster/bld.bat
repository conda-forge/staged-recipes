perl Makefile.PL INSTALLDIRS=vendor NO_PERLLOCAL=1 NO_PACKLIST=1 MAKE=jom
IF %ERRORLEVEL% NEQ 0 exit /B 1
jom
IF %ERRORLEVEL% NEQ 0 exit /B 1
jom test
:: IF %ERRORLEVEL% NEQ 0 exit /B 1
jom install VERBINST=1
IF %ERRORLEVEL% NEQ 0 exit /B 1
