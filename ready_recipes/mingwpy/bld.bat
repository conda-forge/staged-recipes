for /f "delims=" %%i in ('dir /b *.whl') do set WHL=%%i
%PYTHON% -m pip install %WHL%
if errorlevel 1 exit 1
