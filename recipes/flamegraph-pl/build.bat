@echo off

if not exist "%PREFIX%\Library\bin" (
    mkdir "%PREFIX%\Library\bin"
)

copy "flamegraph.pl" "%PREFIX%\Library\bin\flamegraph.pl" >nul

(
echo @echo off
echo call perl "%PREFIX%\Library\bin\flamegraph.pl" %%*
) > "%PREFIX%\Library\bin\flamegraph.bat"
