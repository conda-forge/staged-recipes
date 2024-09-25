@echo on

cd %SRC_DIR%
go build -ldflags "-X main.revision=conda-forge" -v -o %LIBRARY_PREFIX%\bin\jf.exe
go-licenses save . --ignore "github.com/xi2/xz" --save_path .\library_licenses
