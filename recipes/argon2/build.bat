@echo on
@setlocal EnableDelayedExpansion

make ARGON2_VERSION='%PKG_VERSION%' OPTTARGET='none' LIBRARY_REL='lib' AR='%AR%' install || goto :error
make test || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
