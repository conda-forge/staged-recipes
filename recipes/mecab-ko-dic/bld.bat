mkdir mecab-ko-dic
mkdir "%LIBRARY_PREFIX%\lib\mecab\dic\mecab-ko-dic"
"%LIBRARY_BIN%\mecab-dict-index" -d . -o mecab-ko-dic -f UTF-8 -t UTF-8
cp *.def *.csv mecab-ko-dic
mv mecab-ko-dic %LIBRARY_PREFIX%\lib\mecab\dic\
