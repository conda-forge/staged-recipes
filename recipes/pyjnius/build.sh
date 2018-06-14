PYJNIUS_SHARE=$PREFIX/share/pyjnius
mkdir -p $PYJNIUS_SHARE

make
make tests
pip install --no-deps .


cp build/pyjnius.jar $PYJNIUS_SHARE

# ensure that PYJNIUS_JAR is set correctly
mkdir -p $PREFIX/etc/conda/activate.d
echo 'export PYJNIUS_JAR_BACKUP=$PYJNIUS_JAR' > "$PREFIX/etc/conda/activate.d/pyjnius.sh"
echo 'export PYJNIUS_JAR=$CONDA_PREFIX/share/pyjnius/pyjnius.jar' >> "$PREFIX/etc/conda/activate.d/pyjnius.sh"
mkdir -p $PREFIX/etc/conda/deactivate.d
echo 'export PYJNIUS_JAR=$PYJNIUS_JAR_BACKUP' > "$PREFIX/etc/conda/deactivate.d/pyjnius.sh"
echo 'unset PYJNIUS_JAR_BACKUP' >> "$PREFIX/etc/conda/deactivate.d/pyjnius.sh"
