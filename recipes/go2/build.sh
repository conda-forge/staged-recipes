$PYTHON -m pip install . -vv
# /usr/lib/ is hardcoded in a number of files, so replace with the build
# prefix, which will then be replaced on install with the install prefix.
sed -i "s|/usr/lib/go2|$PREFIX/lib/go2|g" $PREFIX/bin/go2
sed -i "s|/usr/lib/go2|$PREFIX/lib/go2|g" $PREFIX/lib/go2/go2.sh
sed -i "s|/usr/lib/go2|$PREFIX/lib/go2|g" $PREFIX/lib/go2/go2.py
sed -i "s|/usr/lib/go2|$PREFIX/lib/go2|g" $PREFIX/share/man/man1/go2.1
sed -i "s|/usr/bin/python3|$PYTHON|g" $PREFIX/lib/go2/go2.py
