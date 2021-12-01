pushd test
if exist .qmake.stash del /a .qmake.stash
qmake hello.pro
if %ErrorLevel% neq 0 exit /b 1
nmake
if %ErrorLevel% neq 0 exit /b 1
:: Only test that this builds
nmake clean
if %ErrorLevel% neq 0 exit /b 1
