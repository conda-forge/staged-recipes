
%PYTHON% -m sysconfig
dir %PREFIX%\Libs

%PYTHON% -m pip install . ^
  --no-build-isolation ^
  --no-deps ^
  --only-binary :all: ^
  --prefix "%PREFIX%"
if errorlevel 1 exit 1
