set SEMIMAP_INCLUDE=%LIBRARY_PREFIX%\include\semimap
set SEMIMAP_TEST=%LIBRARY_PREFIX%\test

if not exist %SEMI_INCLUDE% mkdir %SEMI_INCLUDE%
if not exist %SEMI_TEST% mkdir %SEMI_TEST%

@REM Copy the header-only library file to the include directory
xcopy /Y semimap.h %SEMIMAP_INCLUDE%

xcopy /Y test.cpp %SEMIMAP_TEST%
