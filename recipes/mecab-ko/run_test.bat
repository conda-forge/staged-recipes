IF EXIST libmecab.dll 
IF EXIST mecab.exe
IF EXIST mecab-cost-train.exe
IF EXIST mecab-dict-gen.exe
IF EXIST mecab-dict-index.exe
IF EXIST mecab-system-eval.exe
IF EXIST mecab-test-gen.exe
IF EXIST libmecab.lib
IF EXIST mecab.h (
  goto success
) ELSE (
  exit 1
)

:success

if errorlevel 1 exit /b 1
