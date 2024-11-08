go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s -X github.com/pdfcpu/pdfcpu/pkg/pdfcpu.VersionStr=%PKG_VERSION%" .\cmd\pdfcpu || goto :error
go-licenses save .\cmd\pdfcpu --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
