cd vcbuild || goto err

call vcbuild64.bat || goto err

call runshort.bat || goto err

if not exist "%LIBRARY_LIB%" (mkdir "%LIBRARY_LIB%" || goto err)
if not exist "%LIBRARY_INC%" (mkdir "%LIBRARY_INC%" || goto err)
if not exist "%LIBRARY_BIN%" (mkdir "%LIBRARY_BIN%" || goto err)

move /y "dist64\libmpdec-2.5.1.lib" "%LIBRARY_LIB%" || goto err
move /y "dist64\libmpdec++-2.5.1.lib" "%LIBRARY_LIB%" || goto err

move /y "dist64\libmpdec-2.5.1.dll.lib" "%LIBRARY_LIB%" || goto err
move /y "dist64\libmpdec++-2.5.1.dll.lib" "%LIBRARY_LIB%" || goto err

move /y "dist64\libmpdec-2.5.1.dll" "%LIBRARY_BIN%" || goto err
move /y "dist64\libmpdec++-2.5.1.dll" "%LIBRARY_BIN%" || goto err

move /y "dist64\mpdecimal.h" "%LIBRARY_INC%" || goto err
move /y "dist64\decimal.hh" "%LIBRARY_INC%" || goto err

cd .. || goto err

:success
exit /B 0

:err
exit /B 1
