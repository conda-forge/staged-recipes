set -eux

export CMAKE_ARGS="${CMAKE_ARGS} -DPython3_FIND_STRATEGY=LOCATION"
${PYTHON} -m pip install --no-build-isolation --no-deps -vv ./python
