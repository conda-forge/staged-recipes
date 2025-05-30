@echo on
@setlocal EnableDelayedExpansion

make STRIP=true OPTFLAGS="-O2" CXX="%CXX%" -j%CPU_COUNT% || goto :error
make PREFIX=%LIBRARY_PREFIX% install || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
