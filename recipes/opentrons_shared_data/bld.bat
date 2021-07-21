set PYTHONPATH=%CD%\scripts
cd shared-data\python\
%PYTHON% setup.py bdist_wheel
%PYTHON% -m pip install dist\{{ name }}-{{ version }}-*.whl

