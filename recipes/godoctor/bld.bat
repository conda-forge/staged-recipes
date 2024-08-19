go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s -X main.version=v%PKG_VERSION%"
go-licenses save . --save_path=license-files
