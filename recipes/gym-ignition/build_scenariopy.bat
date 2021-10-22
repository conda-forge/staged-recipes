set section=##[section]

echo.
echo %section%===================
echo %section%Building scenariopy
echo %section%===================
echo.

:: Print the CI environment
echo ##[group] Environment
set
echo ##[endgroup]
echo.

:: Fix Python package version
sed -i.orig 's|name = scenario|name = scenario\'$'\nversion =|g' scenario\setup.cfg
sed -i.tmp "s|version =|version = $PKG_VERSION|g" scenario\setup.cfg
diff -u scenario\setup.cfg.orig scenario\setup.cfg

:: Disable setuptools_scm
sed -i.orig "s|\[tool.setuptools_scm\]||g" scenario\pyproject.toml
sed -i.tmp 's|root = "../"||g' scenario\pyproject.toml
sed -i.tmp 's|local_scheme = "dirty-tag"||g' scenario\pyproject.toml
diff -u scenario\pyproject.toml.orig scenario\pyproject.toml

:: Delete wheel folder
rmdir /s /q _dist_conda

:: Generate the wheel
%PYTHON% ^
    -m build ^
    --wheel ^
    --outdir _dist_conda\ ^
    --no-isolation ^
    --skip-dependency-check ^
    "-C--global-option=build_ext" ^
    "-C--global-option=-DSCENARIO_BUILD_SHARED_LIBRARY:BOOL=ON" ^
    "-C--global-option=--component=python" ^
    .\scenario\
if errorlevel 1 exit 1

:: Delete the build folder
rmdir /s /q build/

:: Install Python package
%PYTHON% -m pip install ^
    --no-index --find-links=.\_dist_conda\ ^
    --no-build-isolation --no-deps ^
    scenario
if errorlevel 1 exit 1

:: Delete wheel folder
rmdir /s /q _dist_conda\
if errorlevel 1 exit 1

:: Restore original files
move /y scenario\setup.cfg.orig scenario\setup.cfg
if errorlevel 1 exit 1
move /y scenario\pyproject.toml.orig scenario\pyproject.toml
if errorlevel 1 exit 1

echo %section%Finishing: building scenariopy
