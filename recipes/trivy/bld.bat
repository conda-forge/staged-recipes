go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%PKG_NAME%.exe -ldflags="-s" .\cmd\trivy || goto :error
go-licenses save .\cmd\trivy --save_path=license-files --ignore=github.com/csaf-poc/csaf_distribution --ignore=modernc.org/mathutil || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
