autoreconf -vfi
./configure --prefix=$PREFIX --with-readine --with-ui
make
make check
make install
mv $PREFIX/bin/hunspell $PREFIX/bin/.hunspell

# We have to make a wrapper to add a spelling dictionary path to hunspell,
# since none of the default ones are relative to the binary (i.e., can be
# installed as a conda package)
cat <<EOF > $PREFIX/bin/hunspell
#!/bin/sh
export DICPATH='$PREFIX/share/hunspell_dictionaries'
$PREFIX/bin/.hunspell "\$@"
EOF

chmod a+x $PREFIX/bin/hunspell
