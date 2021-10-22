set section=##[section]

echo.
echo %section%=============================
echo %section%Building gym-ignition (py$PY_VER)
echo %section%=============================
echo.

:: Print the CI environment
echo ##[group] Environment
set
echo ##[endgroup]
echo.

:: Fix Python package version
sed -i.orig 's|name = gym_ignition|name = gym_ignition\'$'\nversion =|g' setup.cfg
sed -i.tmp "s|version =|version = $PKG_VERSION|g" setup.cfg
diff -u setup.cfg.orig setup.cfg

:: Disable setuptools_scm
sed -i.orig "s|\[tool.setuptools_scm\]||g" pyproject.toml
sed -i.tmp 's|local_scheme = "dirty-tag"||g' pyproject.toml
diff -u pyproject.toml.orig pyproject.toml

:: Delete wheel folder
rmdir /s /q _dist_conda

:: Install Python package
%PYTHON% -m pip install ^
    --no-build-isolation --no-deps ^
    .
if errorlevel 1 exit 1

:: Restore original files
move /y setup.cfg.orig setup.cfg
if errorlevel 1 exit 1
move /y pyproject.toml.orig pyproject.toml
if errorlevel 1 exit 1

echo "${section}Finishing: building gym-ignition"
