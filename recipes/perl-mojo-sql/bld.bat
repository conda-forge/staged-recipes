set PERL_MM_USE_DEFAULT=1

:: If it has Build.PL use that, otherwise use Makefile.PL
IF exist Build.PL (
    perl Build.PL --installdirs vendor --prefix %PREFIX%
    IF %ERRORLEVEL% NEQ 0 exit /B 1
    perl Build
    IF %ERRORLEVEL% NEQ 0 exit /B 1
    perl Build test
    IF %ERRORLEVEL% NEQ 0 exit /B 1
    perl Build install --installdirs vendor
    IF %ERRORLEVEL% NEQ 0 exit /B 1
) ELSE IF exist Makefile.PL (
    perl Makefile.PL INSTALLDIRS=vendor PREFIX=%PREFIX%
    IF %ERRORLEVEL% NEQ 0 exit /B 1
    make
    IF %ERRORLEVEL% NEQ 0 exit /B 1
    make test
    IF %ERRORLEVEL% NEQ 0 exit /B 1
    make install
    IF %ERRORLEVEL% NEQ 0 exit /B 1
) ELSE (
    ECHO 'Unable to find Build.PL or Makefile.PL. You need to modify bld.bat.'
    exit 1
)
:: Add more build steps here, if they are necessary.
:: See
:: https://docs.conda.io/projects/conda-build
:: for a list of environment variables that are set during the build process.
