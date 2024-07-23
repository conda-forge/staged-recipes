go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s -w -X main.Tag=v%PKG_VERSION%"
go-licenses save . --save_path=license-files
