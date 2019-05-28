export AMBERHOME=${PWD}/amber18
cd $AMBERHOME
./configure  --with-python /usr/bin/python3.6 --python-install local gnu
bash amber.sh
make install