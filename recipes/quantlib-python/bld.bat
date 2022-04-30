
set QL_DIR=C:\Miniconda\
copy /f  %RECIPE_DIR%\quantlib.hpp %PREFIX%\Library\include\ql

cd Python
python setup.py build
python setup.py test
python setup.py install

