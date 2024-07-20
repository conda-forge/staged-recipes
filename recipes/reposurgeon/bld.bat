make || goto :error
make install prefix=%LIBRARY_PREFIX || goto :error
go-licenses save ./cutter --save_path=license-files_repocutter --ignore github.com/termie/go-shutil || goto :error
go-licenses save ./mapper --save_path=license-files_repomapper --ignore github.com/termie/go-shutil || goto :error
go-licenses save ./surgeon --save_path=license-files_reposurgeon --ignore github.com/termie/go-shutil || goto :error
go-licenses save ./tool --save_path=license-files_repotool --ignore github.com/termie/go-shutil || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
