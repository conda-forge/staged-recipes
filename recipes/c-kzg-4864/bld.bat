
%PYTHON% -m sysconfig
dir %PREFIX%\Lib
dir %PREFIX%\Library\lib
dir %BUILD_PREFIX%\Lib
dir %BUILD_PREFIX%\Library\lib
dir C:\Users\VssAdministrator\AppData\Roaming\Python
dir C:\Users\VssAdministrator\AppData\Roaming\Python\Python*
dir C:\Users\VssAdministrator\AppData\Roaming\Python\Python*\site-packages
dir C:\Users\VssAdministrator\AppData\Roaming\Python\Python*\site-packages\*

%PYTHON% -m pip install . ^
  --no-build-isolation ^
  --no-deps ^
  --only-binary :all: ^
  --prefix "%PREFIX%"
if errorlevel 1 exit 1
