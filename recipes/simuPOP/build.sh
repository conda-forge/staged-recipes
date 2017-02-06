export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

python setup.py --single-version-externally-managed --record record.txt
