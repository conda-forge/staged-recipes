@rem Remember to activate Intel Compiler, or remove these two lines to ise Microsoft Visual Studio compiler

%PYTHON% setup.py build --force install --old-and-unmanageable
if errorlevel 1 exit 1
