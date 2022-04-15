
@echo off

SetLocal EnableExtensions EnableDelayedExpansion

set WIP=0
for /D %%G in ("%ProgramFiles%\Java\jdk1.8.0_*") do (
  for /F "tokens=2,3,4 delims=-._" %%H in ("%%~nxG") do (
    if %%J GTR !WIP! (
      set WIP=%%J
      set "ORACLE_JDK_DIR=%%G"
    )
  )
)

echo Oracle JDK Home %ORACLE_JDK_DIR%
