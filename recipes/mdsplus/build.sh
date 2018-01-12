./configure --prefix=$PREFIX --enable-shared --disable-java --disable-dependency-tracking --with-readline=$PREFIX --with-xml-prefix=$PREFIX CFLAGS="-I${PREFIX}/include -I${PREFIX}/include/libxml2 $CFLAGS"
export CFLAGS="-I${PREFIX}/include -I${PREFIX}/include/libxml2 $CFLAGS"
make
make install
cd mdsobjects/python
python setup.py install --single-version-externally-managed --record record.txt
