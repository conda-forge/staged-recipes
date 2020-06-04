SET GOPATH="%RECIPE_DIR%\go"
SET GOBIN="%GOPATH%\bin"

go env -w GOPATH="%RECIPE_DIR%\go"
go env -w GOBIN="%GOPATH%\bin"

echo "Yarn"

mkdir ui\node_modules
yarn --cwd ui install --frozen-lockfile --ignore-optional --non-interactive 

mkdir ui\dist\app
yarn --cwd ui build

echo "Get staticfiles"

go get bou.ke\staticfiles
if errorlevel 1 exit /b 1

$GOBIN/staticfiles -o server\static\files.go ui\dist\app
if errorlevel 1 exit /b 1

SET CGO_ENABLED=0
SET GOARCH=amd64
SET GOOS=windows

echo "Build"

mkdir %CD%\dist
go build -v -i -ldflags "-extldflags "-static" -X github.com\argoproj\argo.version=$VERSION" -o dist\argo.exe %CD%\cmd\argo
if errorlevel 1 exit /b 1

echo "Install binary"

mkdir %PREFIX%\bin
mv dist\argo.exe %PREFIX%\bin
if errorlevel 1 exit /b 1
