make -j%CPU_COUNT% LD=%CC% CC=%CC% LDFLAGS=%LDFLAGS% PREFIX=%LIBRARY_PREFIX% install || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
