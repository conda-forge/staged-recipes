@echo on
rmdir recipe /s
cd src
%PYTHON% -m pip install . -vv
