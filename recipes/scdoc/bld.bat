make LDFLAGS=%LDFLAGS% PREFIX=%LIBRARY_PREFIX% -j%CPU_COUNT% || goto :error
make install PREFIX=%LIBRARY_PREFIX% || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
