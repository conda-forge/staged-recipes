
:: As taken from the README for zpaq
cl /O2 /EHsc zpaq.cpp libzpaq.cpp advapi32.lib || exit 1
copy zpaq.exe %PREFIX%\bin || exit 1
