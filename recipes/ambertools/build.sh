export AMBERHOME=${PWD}
#cd $AMBERHOME
echo 'N' | ./configure  -noX11 -openmp -prefix ${PREFIX} --with-python ${PREFIX}/bin/python --python-install local gnu
bash amber.sh
make install
