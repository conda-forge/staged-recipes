unzip dict-en.oxt
mkdir -p $PREFIX/share/hunspell_dictionaries
mv ./*.dic ./*.aff $PREFIX/share/hunspell_dictionaries
