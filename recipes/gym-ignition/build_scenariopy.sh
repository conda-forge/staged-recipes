section="##[section]"

echo
echo "${section}==========================="
echo "${section}Building scenariopy (py$PY_VER)"
echo "${section}==========================="
echo

# Print the CI environment
echo "##[group] Environment"
env
echo "##[endgroup]"
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

# Create a temp dist folder
dist_folder=$(mktemp -d)

# Delete the build folder
rm -rf build/

# Generate the wheel
$PYTHON \
    -m build \
    --wheel \
    --outdir ${dist_folder}/ \
    --no-isolation \
    --skip-dependency-check \
    "-C--global-option=build_ext" \
    "-C--global-option=-DSCENARIO_BUILD_SHARED_LIBRARY:BOOL=ON" \
    "-C--global-option=--component=python" \
    ./scenario/

# Delete the build folder
rm -rf build/

# Install Python package
pip install \
  --no-index --find-links=${dist_folder}/ \
  --no-build-isolation --no-deps \
  scenario

# Restore original files
mv scenario/setup.cfg{.orig,}
mv scenario/pyproject.toml{.orig,}

echo "${section}Finishing: building scenariopy"