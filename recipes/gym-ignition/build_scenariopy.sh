# Fix Python package version
sed -i.bak "s|name = scenario|name = scenario\nversion=$PKG_VERSION|g" setup.cfg
sed -i.bak "s|\[tool.setuptools_scm\]||g" pyproject.toml
sed -i.bak 's|root = "../"||g' pyproject.toml
sed -i.bak 's|local_scheme = "dirty-tag"||g' pyproject.toml

cat setup.cfg
echo
cat pyproject.toml
echo

$PYTHON \
    -m build \
    --wheel \
    --outdir dist \
    --no-isolation \
    --skip-dependency-check \
    "-C--global-option=build_ext" \
    "-C--global-option=-DSCENARIO_BUILD_SHARED_LIBRARY:BOOL=ON" \
    "-C--global-option=--component=python" \
    ./scenario/
pip install --no-deps dist/*.whl
