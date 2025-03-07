if [ "$PKG_NAME" == "stanalyzer-dev" ]; then
    # just copy files necessary for post-installer
    mkdir $SP_DIR/stanalyzer
    cp $SRC_DIR/conda.build/install.py $SP_DIR/stanalyzer
    cp $SRC_DIR/conda.build/__init__.py $SP_DIR/stanalyzer
else
    export SETUPTOOLS_SCM_PRETEND_VERSION="$PKG_VERSION"
    ${PYTHON} -m pip install --no-deps --ignore-installed .
fi
