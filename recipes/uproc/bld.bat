bash -c "autoreconf -i"
if errorlevel 1 exit 1

FOR /F "tokens=*" %%g IN ('cygpath %PREFIX%') do (SET PREFIX_LINUX=%%g)
if errorlevel 1 exit 1

bash -c "CC=gcc ./configure --prefix=$PREFIX_LINUX"
if errorlevel 1 exit 1

make
if errorlevel 1 exit 1

make install
if errorlevel 1 exit 1
