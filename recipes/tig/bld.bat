bash configure || goto :error
make "prefix=$PREFIX" || goto :error
make install "prefix=$PREFIX" || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
