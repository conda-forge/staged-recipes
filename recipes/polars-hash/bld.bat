%PYTHON% -m pip install . -vv || goto :error

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
