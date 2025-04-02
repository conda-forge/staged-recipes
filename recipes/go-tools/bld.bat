@echo on
@setlocal EnableDelayedExpansion

set cmd_names=^
    auth\authtest ^
    auth\cookieauth ^
    auth\gitauth ^
    auth\netrcauth ^
    bisect ^
    bundle ^
    callgraph ^
    compilebench ^
    deadcode ^
    digraph ^
    eg ^
    file2fuzz ^
    fiximports ^
    go-contrib-init ^
    godex ^
    godoc ^
    goimports ^
    gomvpkg ^
    gonew ^
    gotype ^
    goyacc ^
    html2article ^
    present ^
    present2md ^
    signature-fuzzer\fuzz-driver ^
    signature-fuzzer\fuzz-runner ^
    ssadump ^
    stress ^
    stringer ^
    toolstash

for %%a in (%cmd_names%) do(
    call:build_cmd %%a
)

goto :eof

:build_cmd
set cmd_name=%~1
set cmd_prefix=%cmd_name:~0,2%
if %cmd_prefix% NEQ go (
    set bin_name=go-%cmd_name:/=-%
) else (
    set bin_name=%cmd_name:/=-%
)
go build -modcacherw -buildmode=pie -trimpath -o=%LIBRARY_PREFIX%\bin\%bin_name%.exe -ldflags="-s" .\cmd\%cmd_name% || goto :error
go-licenses save .\cmd\%cmd_name% --save_path=license-files\%cmd_name% || goto :error
goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
