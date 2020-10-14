:: Turn work folder into GOPATH
set GOPATH=%SRC_DIR%
set PATH=%GOPATH%\bin:%PATH%

:: Change to directory with main.go
cd buildifier
cd src\github.com\bazelbuild\buildtools\buildifier
if errorlevel 1 exit 1

:: Build
go get .
go build -v -o %PKG_NAME%.exe -ldflags "-X main.buildVersion=%PKG_VERSION%" .
 .
if errorlevel 1 exit 1

:: Install Binary into %PREFIX%\bin
mkdir -p %PREFIX%\bin
if errorlevel 1 exit 1

mv %PKG_NAME% %PREFIX%\bin\%PKG_NAME%
if errorlevel 1 exit 1
