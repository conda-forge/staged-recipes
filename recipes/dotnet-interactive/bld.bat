setlocal enableextensions
setlocal enabledelayedexpansion


set SOURCE="https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json"

dotnet tool install --add-source %SOURCE% --tool-path "%PREFIX%/dotnet/tools" Microsoft.dotnet-interactive

mkdir "%PREFIX%\share\jupyter"
xcopy "%RECIPE_DIR%\kernels" "%PREFIX%\share\jupyter\kernels" /E /I /F /Y
