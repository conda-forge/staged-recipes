go build -o %PREFIX%\bin\caddy.exe
if errorlevel neq 0 exit 1
go-licenses save . --save_path=.\license-files
if errorlevel neq 0 exit 1
