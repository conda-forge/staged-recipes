rm -rf coincurve.egg-info/SOURCES.txt
rm -rf libsecp256k1

%PYTHON% -m pip install --use-pep517 . -vvv
:: %PYTHON% setup.py install
