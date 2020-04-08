echo on

rem Diagnostics
where go
go env

rem Run go's built-in test, we skip the filepath one, and cmd/go
go tool dist test -k -v -no-rebuild -run=!^^go_test:path/filepath^|go_test:cmd/go$
if errorlevel 1 exit 1

rem Run the failing tests by themselves, this is mostly to get logs
rem They fail on Azure, but succeed on AppVeyor and on local Windows VM
go tool dist test -k -v -no-rebuild -run=^^go_test:cmd/go$
go tool dist test -k -v -no-rebuild -run=^^go_test:path/filepath$

exit 0
