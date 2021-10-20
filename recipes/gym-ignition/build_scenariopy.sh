# Fix Python package version
sed -i.bak "s|name = scenario|name = scenario\nversion=$PKG_VERSION|g" scenario/setup.cfg
sed -i.bak "s|\[tool.setuptools_scm\]||g" scenario/pyproject.toml
sed -i.bak 's|root = "../"||g' scenario/pyproject.toml
sed -i.bak 's|local_scheme = "dirty-tag"||g' scenario/pyproject.toml

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
