%PYTHON% -m pip install . -vv || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1