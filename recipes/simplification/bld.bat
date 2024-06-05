@echo on

set FILENAME="rdp-%RDPTAG%-x86_64-pc-windows-msvc.tar.gz"
set "URL=https://github.com/urschrei/rdp/releases/download/%RDPTAG%/%FILENAME%"
curl -L %URL% -o %FILENAME%
tar -xzvf %FILENAME% -C src\simplification

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1

endlocal
