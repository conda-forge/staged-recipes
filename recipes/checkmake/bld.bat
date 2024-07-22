set BUILDER_NAME="conda-forge"
set BUILDER_EMAIL="conda@conda-forge.org"

mkdir %PREFIX%\bin || goto :error
mkdir %PREFIX%\share\man\man1 || goto :error
make || goto :error
make install || goto :error
mv %PREFIX%\bin\checkmake %PREFIX%\bin\checkmake.exe || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
