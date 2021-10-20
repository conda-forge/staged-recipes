echo
echo "==========================="
echo "Building scenariopy (py$PY_VER)"
echo "==========================="
echo

# Fix Python package version
sed -i.bak "s|name = scenario|name = scenario\nversion=$PKG_VERSION|g" scenario/setup.cfg
diff -u scenario/setup.cfg{.bak,} || true
sed -i.bak "s|\[tool.setuptools_scm\]||g" scenario/pyproject.toml
diff -u scenario/pyproject.toml{.bak,} || true
sed -i.bak 's|root = "../"||g' scenario/pyproject.toml
diff -u scenario/pyproject.toml{.bak,} || true
sed -i.bak 's|local_scheme = "dirty-tag"||g' scenario/pyproject.toml
diff -u scenario/pyproject.toml{.bak,} || true

# Generate wheel
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

# Install Python package
pip install --no-deps dist/*.whl

# Restore original files
mv scenario/setup.cfg{.bak,}
mv scenario/pyproject.toml{.bak,}
