setlocal EnableDelayedExpansion

echo on

%PYTHON% setup.py build
%PYTHON% setup.py install
