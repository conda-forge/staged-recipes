set PYO3_PYTHON=%PYTHON% || goto :error
%PYTHON% -m pip install --ignore-installed --no-deps -vv . || goto :error
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
