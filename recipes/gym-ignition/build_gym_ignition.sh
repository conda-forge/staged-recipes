# Fix Python package version
sed -i "s|name = gym_ignition|name = gym_ignition\nversion=$PKG_VERSION|g" setup.cfg
sed -i "s|\[tool.setuptools_scm\]||g" pyproject.toml
sed -i 's|local_scheme = "dirty-tag"||g' pyproject.toml

pip install --no-build-isolation --no-deps .
