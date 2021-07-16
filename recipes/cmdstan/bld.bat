echo TBB_CXX_TYPE=gcc >> make/local
if errorlevel 1 exit 1
:: echo TBB_INTERFACE_NEW=true >> make/local
if errorlevel 1 exit 1
:: echo TBB_INC=%PREFIX%/Library/include/ >> make/local
if errorlevel 1 exit 1
:: echo TBB_LIB=%PREFIX%/Library/lib/ >> make/local
if errorlevel 1 exit 1
mingw32-make clean-all
if errorlevel 1 exit 1
mingw32-make build -j%CPU_COUNT%
if errorlevel 1 exit 1

Xcopy /s /e . %PREFIX%\bin\cmdstan
if errorlevel 1 exit 1
