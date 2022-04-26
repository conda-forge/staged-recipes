
set QL_DIR=C:\Miniconda\lib

nmake -C Python

nmake -C Python check

nmake -C Python wheel

pip install Python/dist/QuantLib-*.whl
