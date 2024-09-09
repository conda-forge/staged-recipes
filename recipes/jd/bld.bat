@echo on

cd %SRC_DIR%
go build -ldflags "-X main.revision=conda-forge" -v -o %LIBRARY_PREFIX%\bin\jd.exe
go-licenses save . --save_path .\library_licenses