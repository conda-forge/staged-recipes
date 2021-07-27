%CONDA_PREFIX%\libexec\tests ~[random]
if errorlevel 1 exit 1
%PYTHON% -m pytest 
