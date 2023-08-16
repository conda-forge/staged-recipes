rmdir coincurve.egg-info
rmdir libsecp256k1

%PYTHON% -m pip install --use-pep517 . -vvv .
