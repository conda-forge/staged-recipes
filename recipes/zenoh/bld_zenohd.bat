cargo install --locked --bins --root %LIBRARY_PREFIX% --path .\zenohd
if %errorlevel% NEQ 0 exit /b %errorlevel%
