set PYTHONPATH=%CD%\scripts
cd api\
%PYTHON% setup.py bdist_wheel

dir
dir dist
dir dist\*.whl

%PYTHON% -m pip install "%CD%\dist\*.whl"

