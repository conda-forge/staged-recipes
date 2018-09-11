gfortran ./glmnet_python/GLMnet.f -fPIC -fdefault-real-8 -shared -o ./glmnet_python/GLMnet.so
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
