sed -i -e '8,12d' setup.py
head -n 5 proteus/config/default.py > proteus/config/default.py.new
echo "print(sys.platform)" >> proteus/config/default.py.new
tail -n +6 proteus/config/default.py >> proteus/config/default.py.new
mv proteus/config/default.py.new proteus/config/default.py

PROTEUS_PREFIX=$PREFIX python setup.py install
