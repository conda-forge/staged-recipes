set PYTHONPATH=%CD%\scripts
cd shared-data\python\
%PYTHON% setup.py bdist_wheel

dir
dir dist
dir dist\*.whl

%PYTHON% -m pip install "%CD%\dist\*.whl"

