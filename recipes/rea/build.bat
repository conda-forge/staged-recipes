@echo on

call npm pack --ignore-scripts
if %ERRORLEVEL% neq 0 exit /b 1

for %%f in (rea-agents-*.tgz) do set TGZ=%%f

call npm install -g --ignore-scripts --omit=dev --no-audit --no-fund --prefix "%LIBRARY_PREFIX%\lib\rea-agents" .\%TGZ%
if %ERRORLEVEL% neq 0 exit /b 1

rem Remove test fixtures with spaces in their paths (thread-stream)
powershell -NoProfile -Command "Get-ChildItem -Recurse -Force '%LIBRARY_PREFIX%\lib\rea-agents' | Where-Object { $_.Name -match ' ' } | Sort-Object { $_.FullName.Length } -Descending | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"

rem Launchers on PATH in Library\bin pointing at the installed entry point
if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
echo @echo off> "%LIBRARY_BIN%\rea.cmd"
echo node "%%~dp0..\lib\rea-agents\node_modules\rea-agents\scripts\rea.mjs" %%*>> "%LIBRARY_BIN%\rea.cmd"
echo @echo off> "%LIBRARY_BIN%\rea-agents.cmd"
echo node "%%~dp0..\lib\rea-agents\node_modules\rea-agents\scripts\rea.mjs" %%*>> "%LIBRARY_BIN%\rea-agents.cmd"

rem Remove npm's own shims, which are not relocatable
if exist "%LIBRARY_PREFIX%\lib\rea-agents\rea.cmd" del "%LIBRARY_PREFIX%\lib\rea-agents\rea.cmd"
if exist "%LIBRARY_PREFIX%\lib\rea-agents\rea-agents.cmd" del "%LIBRARY_PREFIX%\lib\rea-agents\rea-agents.cmd"

exit /b 0