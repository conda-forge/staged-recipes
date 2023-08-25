rm -rf coincurve.egg-info/SOURCES.txt
rm -rf libsecp256k1

%PYTHON% -m pip install --use-pep517 --user --prefix=%PREFIX% . -vvv
rem %PYTHON% setup.py install
