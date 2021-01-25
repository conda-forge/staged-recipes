cd src 
if errorlevel 1 exit 1
nmake -f Makefile.msvc.x64.in
if errorlevel 1 exit 1

copy mecab.h "%PREFIX%\include\"
copy libmecab.dll libmecab.lib "%PREFIX%\lib\" 
copy mecab.exe mecab-cost-train.exe mecab-dict-gen.exe mecab-dict-index.exe mecab-system-eval.exe mecab-test-gen.exe "%PREFIX%\bin\"

if errorlevel 1 exit 1
