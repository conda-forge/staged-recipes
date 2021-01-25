IF EXIST "%PREFIX%\lib\libmecab.dll"
IF EXIST "%PREFIX%\bin\mecab.exe"
IF EXIST "%PREFIX%\bin\mecab-cost-train.exe"
IF EXIST "%PREFIX%\bin\mecab-dict-gen.exe"
IF EXIST "%PREFIX%\bin\mecab-dict-index.exe"
IF EXIST "%PREFIX%\bin\mecab-system-eval.exe"
IF EXIST "%PREFIX%\bin\mecab-test-gen.exe"
IF EXIST "%PREFIX%\lib\libmecab.lib"
IF EXIST "%PREFIX%\include\mecab.h" (
  goto success
) ELSE (
  exit 1
)

:success

if errorlevel 1 exit /b 1
