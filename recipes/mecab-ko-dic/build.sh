#!/usr/bin/env sh

set -e
set +x

mkdir mecab-ko-dic
mkdir -p "$PREFIX/lib/mecab/dic/"
"$PREFIX/libexec/mecab/mecab-dict-index" -d . -o mecab-ko-dic -f UTF-8 -t UTF-8
cp *.def *.csv dicrc mecab-ko-dic
mv mecab-ko-dic "$PREFIX/lib/mecab/dic/"
