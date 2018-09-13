gfortran ./glmnet_python/GLMnet.f -fPIC -fdefault-real-8 -shared -o ./glmnet_python/GLMnet.so
$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
