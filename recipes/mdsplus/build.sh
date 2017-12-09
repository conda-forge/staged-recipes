./configure --prefix=$PREFIX --enable-shared --disable-java --disable-dependency-tracking --with-readline=$PREFIX
make
make install
cd mdsobjects/python
python setup.py install --single-version-externally-managed --record record.txt
