# cmake -DCMAKE_BUILD_TYPE=Release -DINSTALL_OUTPUT_PREFIX=${PREFIX}
# make -j2
$PYTHON setup.py install
echo "PREFIX=${PREFIX}"
ls -l
ls -l ${PREFIX}


