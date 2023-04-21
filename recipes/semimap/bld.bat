if not exist %LIBRARY_PREFIX%\include\semimap mkdir %LIBRARY_PREFIX%\include\semimap

@REM Copy the header-only library file to LIBRARY_PREFIX
xcopy /Y semimap.h %LIBRARY_PREFIX%\include\semimap
