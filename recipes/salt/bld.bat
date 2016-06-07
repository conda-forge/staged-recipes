%PYTHON% -c "import os; import sys; import urllib; urllib.urlretrieve('http://repo.saltstack.com/windows/dependencies/64/libeay32.dll', filename=os.path.join(os.path.dirname(sys.executable), 'libeay32.dll')"
%PYTHON% -c "import os; import sys; import urllib; urllib.urlretrieve('http://repo.saltstack.com/windows/dependencies/64/ssleay32.dll', filename=os.path.join(os.path.dirname(sys.executable), 'ssleay32.dll')"


%PYTHON% setup.py install
if errorlevel 1 exit 1

for %%D in (
       etc\salt
       var\cache\salt
       var\run\salt
       srv\salt
       srv\pillar
       var\log\salt
       var\run
) do (
       if not exist  %PREFIX%\"%%D" mkdir %PREFIX%\"%%D"
)
