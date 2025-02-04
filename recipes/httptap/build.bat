:: Build httptap using Go
go build -ldflags "-X main.revision=conda-forge" -v -o %LIBRARY_PREFIX%\bin\httptap.exe

:: Generate licenses
go-licenses save . --save_path=.\library_licenses
