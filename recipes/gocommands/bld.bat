@echo off

set PKG=github.com/cyverse/gocommands
set VERSION=v%PKG_VERSION%

SET BUILD_DATE=%date%-%time%
set LDFLAGS="-X '%PKG%/commons.clientVersion=%VERSION%' -X '%PKG%/commons.buildDate=%BUILD_DATE%'"
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
go build -v -ldflags=%LDFLAGS% -o gocmd .\cmd\gocmd.go
copy gocmd.exe %PREFIX%\bin\gocmd.exe

echo "{{ range . }}" > ./thirdparty_license_template
echo "## {{ .Name }}" >> ./thirdparty_license_template
echo "" >> ./thirdparty_license_template
echo "* Name: {{ .Name }}" >> ./thirdparty_license_template
echo "* Version: {{ .Version }}" >> ./thirdparty_license_template
echo "* License: [{{ .LicenseName }}]({{ .LicenseURL }})" >> ./thirdparty_license_template
echo "```" >> ./thirdparty_license_template
echo "{{ .LicenseText }}" >> ./thirdparty_license_template
echo "```" >> ./thirdparty_license_template
echo "{{ end }}" >> ./thirdparty_license_template

go-licenses report .\cmd --template .\thirdparty_license_template > THIRDPARTY_LICENSES