SET GOPATH="%RECIPE_DIR%\go"
SET GOBIN="%GOPATH%\bin"

mkdir -p ui\node_modules
yarn --cwd ui install --frozen-lockfile --ignore-optional --non-interactive 
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir -p ui\dist\app
yarn --cwd ui build
if %errorlevel% neq 0 exit /b %errorlevel%

go get bou.ke\staticfiles
if %errorlevel% neq 0 exit /b %errorlevel%

$GOBIN/staticfiles -o server\static\files.go ui\dist\app
if %errorlevel% neq 0 exit /b %errorlevel%

SET CGO_ENABLED=0
SET GOARCH=amd64
SET GOOS=windows

mkdir -p %CD%\dist
go build -v -i -ldflags "-extldflags "-static" -X github.com\argoproj\argo.version=$VERSION" -o dist\argo.exe %CD%\cmd\argo
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir -p %PREFIX%\bin
mv dist\argo.exe %PREFIX%\bin
if %errorlevel% neq 0 exit /b %errorlevel%
