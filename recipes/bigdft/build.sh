# Files
cp $RECIPE_DIR/conda.rc .
cp -r $RECIPE_DIR/licenses .

# Build
export JHBUILD_RUN_AS_ROOT="please do it"
mkdir build
cd build
python ../Installer.py -y autogen
python ../Installer.py -y build -f ../conda.rc

python $RECIPE_DIR/backup_variables.py $PREFIX/bin/bigdftvars.sh
cat $PREFIX/bin/*conda.sh

# Activate script
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
