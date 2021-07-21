set PYTHONPATH=%CD%\scripts
cd api\
%PYTHON% setup.py bdist_wheel

dir
dir dist

%PYTHON% -m pip install dist\*.whl

