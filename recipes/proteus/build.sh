sed -i -e '8,12d' setup.py
PROTEUS_PREFIX=$PREFIX python setup.py install
