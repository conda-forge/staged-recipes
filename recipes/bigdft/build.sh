# Files
cp $RECIPE_DIR/conda.rc .
cp $RECIPE_DIR/patches/* .

# Patches
patch futile/flib/utils.c utils.patch
patch bigdft/src/output.f90 output.patch
cp pybigdft.patch PyBigDFT/pyproject.toml

# Build
export JHBUILD_RUN_AS_ROOT="please do it"
mkdir build
cd build
python ../Installer.py -y autogen
python ../Installer.py -y build -f ../conda.rc

# Activate script
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
