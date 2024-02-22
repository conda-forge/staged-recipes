@echo on
rmdir /s /q recipe
cd src
%PYTHON% -m pip install . -vv
