set DIR_NAME=%PKG_NAME:-=_%
cd %DIR_NAME%
%PYTHON% -m pip install . --no-deps -vv
