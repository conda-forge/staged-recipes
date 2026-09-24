@echo on
setlocal EnableDelayedExpansion

set CGO_ENABLED=0

:: upstream's buildscripts\gen-ldflags.go calls `git log`, which fails on a tarball
:: source, so reproduce its flags from the release tag set in recipe.yaml
set "RELEASE_DATE=%RELEASE:~0,10%"
set "RELEASE_TIME=%RELEASE:~11%"
set "RELEASE_TIME=%RELEASE_TIME:-=:%"
set "VERSION=%RELEASE_DATE%T%RELEASE_TIME%"
set "LDFLAGS=-s -w"
set "LDFLAGS=%LDFLAGS% -X github.com/minio/minio/cmd.Version=%VERSION%"
set "LDFLAGS=%LDFLAGS% -X github.com/minio/minio/cmd.CopyrightYear=%RELEASE:~0,4%"
set "LDFLAGS=%LDFLAGS% -X github.com/minio/minio/cmd.ReleaseTag=RELEASE.%RELEASE%"

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
go build -tags kqueue -trimpath -ldflags "%LDFLAGS%" -o "%LIBRARY_BIN%\silo.exe"
if %errorlevel% neq 0 exit /b %errorlevel%

:: collect licenses of dependencies
go-licenses save . ^
    --save_path="%SRC_DIR%\library_licenses"  ^
    --ignore github.com/apache/thrift/lib/go/thrift ^
    --ignore github.com/minio/colorjson ^
    --ignore github.com/minio/csvparser ^
    --ignore github.com/minio/filepath ^
    --ignore github.com/minio/console ^
    --ignore github.com/minio/dperf ^
    --ignore github.com/minio/kms-go/kes ^
    --ignore github.com/minio/kms-go/kms ^
    --ignore github.com/minio/mc ^
    --ignore  github.com/minio/madmin-go/v3 ^
    --ignore github.com/minio/minio ^
    --ignore github.com/minio/pkg/v3 ^
    --ignore github.com/pgsty/silo-pkg/v3

exit /b 0
