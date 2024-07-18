go mod init "github.com/docker/cli" || goto :error
go mod edit -replace "github.com/imdario/mergo@v1.0.0=github.com/imdario/mergo@v0.3.16" || goto :error
go mod tidy -e || goto :error
go mod vendor -e || goto :error
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\docker.exe -ldflags="-s" .\cmd\docker || goto :error

go-licenses save .\cmd\docker --save_path=license-files || goto :error

goto :EOF

:error
echo Failed with #%errorlevel%.
exit 1
