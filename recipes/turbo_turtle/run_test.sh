turbo-turtle -h
turbo-turtle fetch --destination turbo_turtle_fetch
cd $SP_DIR/$PKG_NAME
pytest -vvv -n 4 --ignore=_abaqus_python -m "not systemtest"
