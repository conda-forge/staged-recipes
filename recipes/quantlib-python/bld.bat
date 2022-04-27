
set QL_DIR=C:\Miniconda\lib

cd Python
nmake
nmake check
nmake wheel
pip install Python/dist/QuantLib-*.whl

