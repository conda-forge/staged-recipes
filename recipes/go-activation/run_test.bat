@echo on

rem Diagnostics
where go
if errorlevel 1 exit 1

go env
if errorlevel 1 exit 1

go mod init example.com/hello_world
if [%cross_target_platform%] == [%build_platform%] (
  go run .
  if errorlevel 1 exit 1
) else (
  go build .
  if errorlevel 1 exit 1
)
