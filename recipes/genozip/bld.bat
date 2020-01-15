make all

echo in bat
echo cd is %cd%
echo LIBRARY_BIN is %LIBRARY_BIN%
echo LIBRARY_LIB is %LIBRARY_LIB%
echo PREFIX is %PREFIX%

dir
copy genozip.exe %LIBRARY_BIN%
copy genounzip.exe %LIBRARY_BIN%
copy genols.exe %LIBRARY_BIN%
copy genocat.exe %LIBRARY_BIN%
