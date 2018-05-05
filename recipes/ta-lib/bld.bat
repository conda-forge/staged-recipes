pushd c
pushd make\cdr\win32\msvc
nmake
IF %ERRORLEVEL% == 1; exit 1
popd
copy lib\*.lib %LIBRARY_LIB% /y
copy include\*.h %LIBRARY_INC% /y
copy bin\ta_regtest.exe %LIBRARY_BIN% /y
popd
