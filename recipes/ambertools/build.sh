export AMBERHOME=${PWD}
#cd $AMBERHOME
echo 'N' | ./configure --prefix=${PREFIX}  -noX11 -openmp --with-python ${PREFIX}/bin/python --python-install local gnu
bash amber.sh
make install
