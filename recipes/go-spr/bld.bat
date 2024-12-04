@echo on

go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\amend -ldflags="-s" .\cmd\amend
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\reword -ldflags="-s" .\cmd\reword
go build -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\spr -ldflags="-s" .\cmd\spr
go-licenses save .\cmd\amend --save_path=license-files_amend --ignore github.com/inigolabs/fezzik
go-licenses save .\cmd\reword --save_path=license-files_reword --ignore github.com/inigolabs/fezzik
go-licenses save .\cmd\spr --save_path=license-files_spr --ignore github.com/inigolabs/fezzik
