set BUILDER_NAME="conda-forge"
set BUILDER_EMAIL="conda@conda-forge.org"

mkdir %PREFIX%\bin
mkdir %PREFIX%\share\man\man1
make || goto :error
make install || goto :error
mv %PREFIX%\bin\checkmake %PREFIX%\bin\checkmake.exe
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
