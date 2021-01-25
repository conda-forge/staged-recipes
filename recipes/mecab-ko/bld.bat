cd src 
if errorlevel 1 exit 1
nmake -f Makefile.msvc.x64.in
if errorlevel 1 exit 1
cp *.dll *.exe *.lib mecab.h "%PREFIX%"
if errorlevel 1 exit 1
