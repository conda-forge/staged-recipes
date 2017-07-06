nmake -f mk_mvc.mak
if errorlevel 1 exit 1

copy /B ctags.exe "%LIBRARY_BIN%"
