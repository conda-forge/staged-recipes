rem go one level up
cd %SRC_DIR%
cd ..

rem create the gopath directory structure
set "GOPATH=%CD%\gopath"
mkdir "%GOPATH%\src\github.com\mholt\archiver"
xcopy /s "%SRC_DIR%\*" "%GOPATH%\src\github.com\mholt\archiver\"
cd "%GOPATH%\src\github.com\mholt\archiver"

rem build the project
cd cmd\archiver\
go get -v
go build
if errorlevel 1 exit 1

rem install the binary
mkdir "%LIBRARY_BIN%"
mv "%GOPATH%\bin\archiver" "%LIBRARY_BIN%\archiver"
