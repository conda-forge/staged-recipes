set PYTHONPATH=%CD%\scripts
cd api\
%PYTHON% setup.py bdist_wheel
%PYTHON% -m pip install dist\{{ name }}-{{ version }}-*.whl

