export AMBERHOME=${PWD}/amber18
cd $AMBERHOME
./configure  --with-python ${PREFIX}/bin/python --python-install local gnu
bash amber.sh
make install
