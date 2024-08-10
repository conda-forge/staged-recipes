@echo on

set GO111MODULE=on
set GOPATH=%CONDA_PREFIX%\go

mkdir "%GOPATH%\src\github.com\peco"
xcopy /E /I "%SRC_DIR%" "%GOPATH%\src\github.com\peco\peco"
cd /D "%GOPATH%\src\github.com\peco\peco"

make build

go build ^
    -ldflags "-s -w" ^
    -o "%LIBRARY_BIN%\bin\%PKG_NAME%" ^
    cmd\%PKG_NAME%\%PKG_NAME%.go

