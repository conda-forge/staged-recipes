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

cp libmecab.dll "%PREFIX%\lib\" 
if errorlevel 1 exit 1
cp libmecab.lib "%PREFIX%\lib\" 
if errorlevel 1 exit 1

cp mecab.exe "%PREFIX%\bin\"
if errorlevel 1 exit 1
cp mecab-cost-train.exe "%PREFIX%\bin\"
if errorlevel 1 exit 1
cp mecab-dict-gen.exe "%PREFIX%\bin\"
if errorlevel 1 exit 1
cp mecab-dict-index.exe "%PREFIX%\bin\"
if errorlevel 1 exit 1
cp mecab-system-eval.exe "%PREFIX%\bin\"
if errorlevel 1 exit 1
cp mecab-test-gen.exe "%PREFIX%\bin\"
if errorlevel 1 exit 1

if errorlevel 1 exit /b 1
