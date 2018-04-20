@ECHO ON

REM Make sure to use proper python from conda
REM set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\

set MN_BUILD=boost

python %SRC_DIR%/setup.py build_ext
python %SRC_DIR%/setup.py install
