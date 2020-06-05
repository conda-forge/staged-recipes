echo "Yarn"

mkdir ui\node_modules
yarn --cwd ui install --frozen-lockfile --ignore-optional --non-interactive 
if errorlevel 1 exit /b 1

mkdir ui\dist\app
yarn --cwd ui build
if errorlevel 1 exit /b 1

echo "Get staticfiles"

go get bou.ke\staticfiles
if errorlevel 1 exit /b 1

staticfiles -o server\static\files.go ui\dist\app
if errorlevel 1 exit /b 1
rm %PREFIX%\bin\staticfiles
if errorlevel 1 exit /b 1

echo "Build"

go install -v -i -ldflags "-extldflags "-static" -X github.com\argoproj\argo.version=%VERSION%" -o ./cmd/argo
if errorlevel 1 exit /b 1
