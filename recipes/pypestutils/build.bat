@echo on

:: meson.build rejects optimization=3, which --buildtype=release sets
meson setup builddir %MESON_ARGS% -Doptimization=2 -Ddebug=false
if errorlevel 1 exit 1
meson compile -C builddir -v pestutils
if errorlevel 1 exit 1

:: place the shared library where pypestutils.finder looks first
if not exist pypestutils\lib mkdir pypestutils\lib
copy /B builddir\pestutils\pestutils.dll pypestutils\lib\
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1

:: run the upstream test suite here, since its 77 MB of data files are too
:: large to ship as package test files; tests use paths relative to the repo
:: root, so remove its source package to import the installed one instead
cd upstream
rd /s /q pypestutils
%PYTHON% -m pytest tests -p no:cacheprovider
if errorlevel 1 exit 1
