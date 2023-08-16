rm -r coincurve.egg-info/SOURCES.txt
rm -r libsecp256k1

%PYTHON% -m pip install --use-pep517 . -vvv .
