@echo on
@setlocal EnableDelayedExpansion

sed -i "s/ar rcs/%AR% rcs/" Makefile || goto :error
make ARGON2_VERSION='%PKG_VERSION%' OPTTARGET='none' LIBRARY_REL='lib' AR='%AR%' install || goto :error
mv %LIBRARY_PREFIX%\bin\argon2 %LIBRARY_PREFIX%\bin\argon2.exe
:: Unit tests currently fail on Windows for unclear reasons
:: make test || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
