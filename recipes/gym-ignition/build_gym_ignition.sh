echo
echo "============================="
echo "Building gym-ignition (py$PY_VER)"
echo "============================="
echo

# Print the CI environment
echo "##[group] Environment"
env
echo "##[endgroup]"

# Fix Python package version
sed -i.orig 's|name = gym_ignition|name = gym_ignition\'$'\nversion =|g' setup.cfg
sed -i.tmp "s|version =|version = $PKG_VERSION|g" setup.cfg
diff -u setup.cfg{.orig,} || true

# Disable setuptools_scm
sed -i.orig "s|\[tool.setuptools_scm\]||g" pyproject.toml
sed -i.tmp 's|local_scheme = "dirty-tag"||g' pyproject.toml
diff -u pyproject.toml{.orig,} || true

# Install Python package
pip install --no-build-isolation --no-deps .

# Restore original files
mv setup.cfg{.orig,}
mv pyproject.toml{.orig,}
