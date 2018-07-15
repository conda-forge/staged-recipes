set path=%path%;C:\mingw-w64\x86_64-7.3.0-posix-seh-rt_v5-rev0\bin
%PYTHON% -m pip install --no-deps --ignore-installed .
if errorlevel 1 exit 1
