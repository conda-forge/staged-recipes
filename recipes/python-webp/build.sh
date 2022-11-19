set -ex
rm -f pyproject.toml

# Remove conan from setup_requires
python ${RECIPE_DIR}/rewrite_config.py

cp ${RECIPE_DIR}/builder.py webp_build/builder.py
python -m pip install . -vv --no-deps --no-build-isolation
