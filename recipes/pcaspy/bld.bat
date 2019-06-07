set EPICS_BASE=%PREFIX%\epics
if %ARCH%==32 (
   set EPICS_HOST_ARCH=win32-x86
) else if %ARCH%==64 (
    set EPICS_HOST_ARCH=windows-x64
)
echo Using EPICS_BASE=%EPICS_BASE%
echo Using EPICS_HOST_ARCH=%EPICS_HOST_ARCH%

%PYTHON% -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
