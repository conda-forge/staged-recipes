make STRIP=true OPTFLAGS="-O2" CXX="%CXX%" -j%CPU_COUNT% || goto :error
make PREFIX=%LIBRARY_PREFIX% install || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
