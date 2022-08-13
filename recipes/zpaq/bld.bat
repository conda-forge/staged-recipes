
:: As taken from the README for zpaq
cl /O2 /EHsc zpaq.cpp libzpaq.cpp advapi32.lib || exit 1
copy /B zpaq.exe %LIBRARY_BIN% || exit 1
