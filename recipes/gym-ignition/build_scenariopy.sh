echo
echo "==========================="
echo "Building scenariopy (py$PY_VER)"
echo "==========================="
echo

# Fix Python package version
sed -i.orig 's|name = scenario|name = scenario\'$'\nversion =|g' scenario/setup.cfg
sed -i.tmp "s|version =|version = $PKG_VERSION|g" scenario/setup.cfg
diff -u scenario/setup.cfg{.orig,} || true

# Disable setuptools_scm
sed -i.orig "s|\[tool.setuptools_scm\]||g" scenario/pyproject.toml
sed -i.tmp 's|root = "../"||g' scenario/pyproject.toml
sed -i.tmp 's|local_scheme = "dirty-tag"||g' scenario/pyproject.toml
diff -u scenario/pyproject.toml{.orig,} || true

# Delete wheel folder
rm -rf _dist_conda/

# Generate the wheel
$PYTHON \
    -m build \
    --wheel \
    --outdir _dist_conda \
    --no-isolation \
    --skip-dependency-check \
    "-C--global-option=build_ext" \
    "-C--global-option=-DSCENARIO_BUILD_SHARED_LIBRARY:BOOL=ON" \
    "-C--global-option=--component=python" \
    ./scenario/

# Install Python package
pip install \
  --no-index --find-links=./_dist_conda/ \
  --no-build-isolation --no-deps \
  scenario

# Delete wheel folder
rm -rf _dist_conda/

# Restore original files
mv scenario/setup.cfg{.orig,}
mv scenario/pyproject.toml{.orig,}
