mkdir "%PREFIX%\include\"
if errorlevel 1 exit 1
mkdir "%PREFIX%\bin\"
if errorlevel 1 exit 1
mkdir "%PREFIX%\lib\"
if errorlevel 1 exit 1

cd src 
if errorlevel 1 exit 1
nmake -f Makefile.msvc.x64.in
if errorlevel 1 exit 1

cp mecab.h "%PREFIX%\include\"
if errorlevel 1 exit 1

cp libmecab.* "%PREFIX%\lib\" 
if errorlevel 1 exit 1

cp *.exe "%PREFIX%\bin\"
if errorlevel 1 exit 1

if errorlevel 1 exit /b 1
