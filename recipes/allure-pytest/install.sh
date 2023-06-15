export SETUPTOOLS_SCM_PRETEND_VERSION=${PKG_VERSION}
${PYTHON} -m pip install --no-deps  --no-build-isolation --ignore-installed -vv ./${PKG_NAME}/
