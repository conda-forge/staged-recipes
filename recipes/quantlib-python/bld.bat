
set QL_DIR=C:\Miniconda\
set INCLUDE=C:\Miniconda\include

cd Python
python setup.py build
python setup.py test
python setup.py install

