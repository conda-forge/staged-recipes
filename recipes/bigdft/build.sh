# Files
cp $RECIPE_DIR/conda.rc .

# Build
export JHBUILD_RUN_AS_ROOT="please do it"
mkdir build
cd build
python ../Installer.py -y autogen
python ../Installer.py -y build -f ../conda.rc

# Environment variables
python $RECIPE_DIR/backup_variables.py $PREFIX/bin/bigdftvars.sh
cat $PREFIX/bin/*conda.sh

# Activate script
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"

# Remove Extra Files
rm -r $PREFIX/_jhbuild
rm $PREFIX/lib/libabinit.a
rm $PREFIX/lib/libatlab-1.a
rm $PREFIX/lib/libbigdft-1.a
rm $PREFIX/lib/libCheSS-1.a
rm $PREFIX/lib/libdicts.a
rm $PREFIX/lib/libfutile-1.a
rm $PREFIX/lib/libGaIn.a
rm $PREFIX/lib/liborbs.a
rm $PREFIX/lib/libPSolver-1.a
