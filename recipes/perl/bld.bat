bash Configure -de -Dprefix=$PREFIX -Duserelocatableinc
if errorlevel 1 exit 1

make
if errorlevel 1 exit 1

make test
if errorlevel 1 exit 1

make install
if errorlevel 1 exit 1
