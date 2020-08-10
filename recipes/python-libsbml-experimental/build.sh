echo "Running build.sh"
echo "PWD: ${PWD}"
echo "SRC_DIR: ${SRC_DIR}"
echo "RECIPE_DIR: ${RECIPE_DIR}"
echo "PREFIX: ${PREFIX}"

ls -l

CUR_DIR=${PWD}

export LIBSBML_EXPERIMENTAL=1
export CMAKE_BUILD_PARALLEL_LEVEL=4

$PYTHON -m pip install . --no-deps -vv
