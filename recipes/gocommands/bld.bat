@echo off

set PKG=github.com/cyverse/gocommands
set VERSION=v%PKG_VERSION%

FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse HEAD`) DO (
  SET GIT_COMMIT=%%F
)

SET BUILD_DATE=%date%-%time%
set LDFLAGS="-X '%PKG%/commons.clientVersion=%VERSION%' -X '%PKG%/commons.gitCommit=%GIT_COMMIT%' -X '%PKG%/commons.buildDate=%BUILD_DATE%'"
set GO111MODULE=on
set GOPROXY=direct

FOR /F "tokens=* USEBACKQ" %%F IN (`go env GOPATH`) DO (
  SET GOPATH=%%F
)

set CGO_ENABLED=0

if not exist "%PREFIX%\bin" ( 
    mkdir "%PREFIX%\bin"
    if errorlevel 1 exit 1
)

echo "building gocommands"
go build -ldflags=%LDFLAGS% -o gocmd .\cmd\gocmd.go
copy gocmd.exe %PREFIX%\bin\gocmd.exe
