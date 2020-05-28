:: install python package
%PYTHON% -m pip install --no-deps -vv . || goto :error

:: TODO: copy headers to includedir

:: TODO: cargo build for shared and static libraries
:: TODO: copy libs to prefix/lib

:: maybe TODO? pkgconfig

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
