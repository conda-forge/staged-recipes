cd win
if errorlevel 1 exit 1
nmake /f Makefile.msc FOSSIL_ENABLE_SSL=1 FOSSIL_ENABLE_JSON=1 FOSSIL_ENABLE_TCL=1 FOSSIL_BUILD_ZLIB=0 PERLDIR=%PREFIX%\Library\bin
if errorlevel 1 exit 1
buildmsvc.bat         FOSSIL_ENABLE_SSL=1 FOSSIL_ENABLE_JSON=1 FOSSIL_ENABLE_TCL=1 FOSSIL_BUILD_ZLIB=0 PERLDIR=%PREFIX%\Library\bin
if errorlevel 1 exit 1
