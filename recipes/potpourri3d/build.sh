set -ex

# Overwrite CMakeLists.txt for dynamic linking
rm CMakeLists.txt
cp $RECIPE_DIR/CMakeLists.txt .

python -m pip install . -vv --no-deps --no-build-isolation
