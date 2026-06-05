set PERL_MM_USE_DEFAULT=1

:: If it has Build.PL use that, otherwise use Makefile.PL
IF exist Build.PL (
    perl Build.PL --install_base %PREFIX% --installdirs site
    IF errorlevel 1 exit /b 1
    perl Build
    IF errorlevel 1 exit /b 1
    perl Build test
    IF errorlevel 1 exit /b 1
    perl Build install --installdirs site
    IF errorlevel 1 exit /b 1
) ELSE IF exist Makefile.PL (
    perl Makefile.PL INSTALLDIRS=site PREFIX=%PREFIX%
    IF errorlevel 1 exit /b 1
    make
    IF errorlevel 1 exit /b 1
    make test
    IF errorlevel 1 exit /b 1
    make install
    IF errorlevel 1 exit /b 1
) ELSE (
    ECHO 'Unable to find Build.PL or Makefile.PL. You need to modify bld.bat.'
    exit 1
)

:: DO NOT add activation commands here - the environment is already active
