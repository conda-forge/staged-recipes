:: Turn work folder into GOPATH
set GOPATH=%SRC_DIR%
set PATH=%GOPATH%\bin:%PATH%

:: change package name from bazel_buildozer to buildozer
set PKG_NAME=buildozer

:: Change to directory with main.go
cd bazel_buildozer
cd src\github.com\bazelbuild\buildtools\buildozer
if errorlevel 1 exit 1

:: Build
go get .
go build -v -o %PKG_NAME%.exe -ldflags "-X main.buildVersion=%PKG_VERSION%" .
if errorlevel 1 exit 1

:: Install Binary into %PREFIX%\bin
mkdir -p %PREFIX%\bin
mv %PKG_NAME% %PREFIX%\bin\%PKG_NAME%
if errorlevel 1 exit 1
