#!/usr/bin/env sh 

set -e
set +x

$PREFIX/bin/mecab -v
$PREFIX/bin/mecab -h | grep MeCab
