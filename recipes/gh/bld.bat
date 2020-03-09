:: Turn work folder into GOPATH
set GOPATH=%SRC_DR%
set PATH=%GOPATH%\bin:%PATH%

:: Change to directory with main.go
cd cmd\gh

:: Build
go build -v -o %PKG_NAME%.exe .

:: Install Binary into %PREFIX%\bin
mkdir -p %PREFIX%\bin
mv %PKG_NAME% %PREFIX%\bin\%PKG_NAME%