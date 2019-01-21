cd win
if errorlevel 1 exit 1
nmake /f Makefile.msc FOSSIL_ENABLE_SSL=1 FOSSIL_BUILD_SSL=1 PERLDIR=%PREFIX%\Library\bin
if errorlevel 1 exit 1
buildmsvc.bat FOSSIL_ENABLE_SSL=1 FOSSIL_BUILD_SSL=1 PERLDIR=%PREFIX%\Library\bin
if errorlevel 1 exit 1
