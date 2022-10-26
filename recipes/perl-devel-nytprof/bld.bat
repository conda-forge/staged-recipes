IF exist Build.PL (
    perl Build.PL
    IF %ERRORLEVEL% NEQ 0 exit /B 1
    Build
    IF %ERRORLEVEL% NEQ 0 exit /B 1
    Build test
    Build install --installdirs vendor
    IF %ERRORLEVEL% NEQ 0 exit /B 1
) ELSE IF exist Makefile.PL (
    perl Makefile.PL INSTALLDIRS=vendor
    IF %ERRORLEVEL% NEQ 0 exit /B 1
    make
    IF %ERRORLEVEL% NEQ 0 exit /B 1
    make test
    IF %ERRORLEVEL% NEQ 0 exit /B 1
    make install
) ELSE (
    ECHO 'Unable to find Build.PL or Makefile.PL. You need to modify bld.bat.'
    exit 1
)


