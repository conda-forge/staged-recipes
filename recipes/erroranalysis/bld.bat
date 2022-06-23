type NUL > requirements.txt || goto :error
%PYTHON% -m pip install . -vv || goto :error

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
