set BUILDER_NAME="conda-forge"
set BUILDER_EMAIL="conda@conda-forge.org"

make || goto :error
make install || goto :error
go-licenses save . --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
