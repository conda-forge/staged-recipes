echo
echo "====================="
echo "Building gym-ignition"
echo "====================="
echo

# Fix Python package version
sed -i.bak "s|name = gym_ignition|name = gym_ignition\nversion=$PKG_VERSION|g" setup.cfg
diff -u setup.cfg{.bak,} || true
sed -i.bak "s|\[tool.setuptools_scm\]||g" pyproject.toml
sed -i.bak 's|local_scheme = "dirty-tag"||g' pyproject.toml
diff -u pyproject.toml{.bak,} || true

# Install Python package
pip install --no-build-isolation --no-deps .

# Restore original files
mv setup.cfg{.bak,}
mv pyproject.toml{.bak,}
