cd %SRC_DIR%
dotnet tool restore
dotnet publish src\ArcCommander -c Release -p:UseAppHost=false
set DOTNET_ROOT="%PREFIX%\dotnet"
set TOOL_ROOT="%DOTNET_ROOT%\tools\arccommander"
mkdir %PREFIX%\bin %TOOL_ROOT%
robocopy /E %SRC_DIR%\src\ArcCommander\bin\X64\Release\net6.0\ %TOOL_ROOT%
copy "%RECIPE_DIR%\arc.bat" "%PREFIX%\bin\arc.bat"