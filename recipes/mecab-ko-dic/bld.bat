mkdir mecab-ko-dic
if errorlevel 1 exit 1

mkdir "%LIBRARY_PREFIX%\lib\mecab\dic\mecab-ko-dic"
if errorlevel 1 exit 1

"%LIBRARY_BIN%\mecab-dict-index" -d . -o mecab-ko-dic -f UTF-8 -t UTF-8
if errorlevel 1 exit 1

cp *.def *.csv dicrc mecab-ko-dic
if errorlevel 1 exit 1

mv mecab-ko-dic %LIBRARY_PREFIX%\lib\mecab\dic\
if errorlevel 1 exit 1

if errorlevel 1 exit /b 1
