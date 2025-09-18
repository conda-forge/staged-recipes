@echo off
setlocal enabledelayedexpansion

set "HYDRA_HOME=%CONDA_PREFIX%\lib\hydra-java"
set "CLASSPATH="

for /r "%HYDRA_HOME%" %%f in (*.jar) do (
    if defined CLASSPATH (
        set "CLASSPATH=!CLASSPATH!;%%f"
    ) else (
        set "CLASSPATH=%%f"
    )
)

java -cp "%CLASSPATH%" %*
