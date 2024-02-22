@echo on

set GO111MODULE=on

cd %SRC_DIR%
go build -ldflags "-X main.revision=conda-forge" -v -o %LIBRARY_PREFIX%\bin\hugo.exe
go-licenses save . --save_path .\library_licenses
