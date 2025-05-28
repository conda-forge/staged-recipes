@echo on
setlocal enabledelayedexpansion

make init
make build

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
copy /Y zasper.exe %PREFIX%\bin\zasper.exe

go-licenses save . --save_path="./license-files/"
