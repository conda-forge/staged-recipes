@echo on

go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\ejson-kms.exe -ldflags="-s"
go-licenses save . --save_path=license-files
