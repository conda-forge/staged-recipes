cd src 
if errorlevel 1 exit 1
nmake -f Makefile.msvc.x64.in
if errorlevel 1 exit 1

cp mecab.h "%PREFIX%\include\"
cp libmecab.dll "%PREFIX%\lib\" 
cp libmecab.lib "%PREFIX%\lib\" 

cp mecab.exe "%PREFIX%\bin\"
cp mecab-cost-train.exe "%PREFIX%\bin\"
cp mecab-dict-gen.exe "%PREFIX%\bin\"
cp mecab-dict-index.exe "%PREFIX%\bin\"
cp mecab-system-eval.exe "%PREFIX%\bin\"
cp mecab-test-gen.exe "%PREFIX%\bin\"

if errorlevel 1 exit 1
