set PYTHONPATH=%CD%\scripts
cd shared-data\python\
%PYTHON% setup.py bdist_wheel

dir
dir dist

%PYTHON% -m pip install dist\*.whl

