nmake -f Makefile.wnm
if not exist %PREFIX%\bin mkdir %PREFIX%\bin
copy less.exe lesskey.exe lessecho.exe %PREFIX%\bin\
