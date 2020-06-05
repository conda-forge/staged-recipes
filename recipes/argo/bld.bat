set PYTHON=%BUILD_PREFIX%\python.exe
call yarn --cwd ui install --frozen-lockfile --ignore-optional --non-interactive
if errorlevel 1 exit /b 1
call yarn --cwd ui build
rem build throws a warning on Windows
rem if errorlevel 1 exit /b 1

go get bou.ke\staticfiles
if errorlevel 1 exit /b 1
%PREFIX%\bin\staticfiles -o server\static\files.go ui\dist\app
if errorlevel 1 exit /b 1
rm %PREFIX%\bin\staticfiles
if errorlevel 1 exit /b 1

go install -v -i -ldflags "-extldflags "-static" -X github.com\argoproj\argo.version=%VERSION%" ./cmd/argo
if errorlevel 1 exit /b 1
