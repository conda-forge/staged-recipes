# TODO: Remove MANIFEST monkey patch when Turbo-Turtle is released with a MANIFEST and better subdirectory handling
echo "recursive-include turbo_turtle/tutorials *" > MANIFEST.in
$PYTHON -m build --no-isolation
$PYTHON -m pip install dist/$PKG_NAME-$PKG_VERSION.tar.gz --no-deps --ignore-installed -v --no-build-isolation
scons man html
$PYTHON package_documentation.py
