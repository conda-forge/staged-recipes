nmake /f makefile.vc

nmake INSTDIR=%LIBRARY_PREFIX% /f makefile.vc install-all
if errorlevel 1 exit 1

move %LIBRARY_PREFIX%\bin\*.* %PREFIX%
if errorlevel 1 exit 1
