echo ON

autoreconf --install
if errorlevel 1 exit 1

./configure --prefix=%PREFIX%
if errorlevel 1 exit 1

make
if errorlevel 1 exit 1

make install
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv
if errorlevel 1 exit 1
