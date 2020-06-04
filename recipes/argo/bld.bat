SET GOPATH="%RECIPE_DIR%\go"
SET GOBIN="%GOPATH%\bin"

mkdir -p ui\node_modules
yarn --cwd ui install --frozen-lockfile --ignore-optional --non-interactive

mkdir -p ui\dist\app
yarn --cwd ui build

go get bou.ke\staticfiles
$GOBIN/staticfiles -o server\static\files.go ui\dist\app

SET CGO_ENABLED=0
SET GOARCH=amd64
SET GOOS=windows

mkdir -p %CD%\dist
go build -v -i -ldflags "-extldflags "-static" -X github.com\argoproj\argo.version=$VERSION" -o dist\argo.exe %CD%\cmd\argo

mkdir -p %PREFIX%\bin
mv dist\argo.exe %PREFIX%\bin
