:: Rewrite make.inc to comply with conda build
> make.inc (
    @echo.LIBS = -lgsl -lgslcblas -ldistfit -lmsa -ldssplite -ldltmath -lDLTutils -ltheseus
    @echo.SYSLIBS = -lpthread -lgsl -lgslcblas -lm -lc
    @echo.LIBDIR = -L./lib
    @echo.INSTALLDIR = %SCRIPTS%
    @echo.RANLIB = %RANLIB%
)

:: ARCH defaults to "64" (bit) in conda-build, this should be AR!
sed -i.bak -e 's/\$(ARCH)/$(AR)/g' ^
           -e 's/\$(ARCHFLAGS)/rvs/g' ^
           Makefile lib*/Makefile

jom
jom install
