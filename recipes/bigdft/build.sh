# Files
cp $RECIPE_DIR/conda.rc .
cp $RECIPE_DIR/patch*.txt .

# Patches
patch futile/flib/utils.c patch_utils.txt 
patch bigdft/src/output.f90  patch_output.txt 

# Build
mkdir build
cd build
python ../Installer.py -y autogen
python ../Installer.py -y build -f ../conda.rc

# Activate script
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
