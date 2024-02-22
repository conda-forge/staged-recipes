@echo on
rmdir /s recipe
cd src
%PYTHON% -m pip install . -vv
