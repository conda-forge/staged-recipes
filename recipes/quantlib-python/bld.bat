
set QL_DIR=C:\Miniconda\

echo "Overwriting quantlib.hpp"
copy /y %RECIPE_DIR%\quantlib.hpp %PREFIX%\Library\include\ql\quantlib.hpp

cd Python
python setup.py build
python setup.py test
python setup.py install

