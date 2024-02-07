:: If it has Build.PL use that, otherwise use Makefile.PL
IF exist Build.PL (
    perl Build.PL
    IF errorlevel 1 exit 1
    Build
    IF errorlevel 1 exit 1
    Build test
    Build install --installdirs vendor
    IF errorlevel 1 exit 1
) ELSE IF exist Makefile.PL (
    perl Makefile.PL INSTALLDIRS=vendor
    IF errorlevel 1 exit 1
    make
    IF errorlevel 1 exit 1
    make test
    IF errorlevel 1 exit 1
    make install
) ELSE (
    ECHO 'Unable to find Build.PL or Makefile.PL. You need to modify bld.bat.'
    exit 1
)

