REM Do not include test folders in package or it will
REM cause a conda clobber warning
del /S /Q test*
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
