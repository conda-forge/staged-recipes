${PYTHON} -m pip install . -vv

PYTHON_SITE_PACKAGES=$(python -c "import os; from sysconfig import get_paths; print(os.path.relpath(get_paths()['purelib'], '${PREFIX}'))")
chmod ug+x ${PREFIX}/${PYTHON_SITE_PACKAGES}/mintpy/*.py

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}-${CHANGE}.sh"
done
