go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s -X github.com/rhysd/actionlint.version=%PKG_VERSION%" .\cmd\%PKG_NAME%
go-licenses save . --save_path=license-files
