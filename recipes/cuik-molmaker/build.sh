# Get Python version from conda-build environment (e.g., 3.11, 3.12, 3.13)
export PYTHON_VERSION=${PY_VER}

CXX11_ABI="ON"

# Validate RDKit version format (year.minor.patch)
if [[ ! $RDKIT_VERSION =~ ^[0-9]{4}\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: RDKit version must be in the format: year.minor.patch (e.g., 2023.3.4)"
    exit 1
fi

# Validate Python version
if [[ ! $PYTHON_VERSION =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Python version must be in the format: year.minor (e.g., 3.11)"
    exit 1
fi

echo "CONDA_PREFIX:"
echo "${CONDA_PREFIX}"
echo "BUILD_PREFIX:"
echo "${BUILD_PREFIX}"
set -x

# Hack for RDkit expecting things in python3.9 folder
# ln -s $CONDA_PREFIX/lib/python$PYTHON_VERSION $CONDA_PREFIX/lib/python3.9
# ln -s $CONDA_PREFIX/include/python$PYTHON_VERSION $CONDA_PREFIX/include/python3.9

# Build C++ extension
RDKIT_VERSION=${RDKIT_VERSION}  PYTHON_VERSION=${PYTHON_VERSION} CUIKMOLMAKER_CXX11_ABI=${CXX11_ABI} $PYTHON setup.py build_ext --inplace

# Set the wheel directory
export WHL_DIR=cm_py${PYTHON_VERSION}_rdkit-${RDKIT_VERSION}_dist

# Build wheel
RDKIT_VERSION=${RDKIT_VERSION}   PYTHON_VERSION=${PYTHON_VERSION} CUIKMOLMAKER_CXX11_ABI=${CXX11_ABI} $PYTHON setup.py bdist_wheel --dist-dir ${WHL_DIR}

# Install the package from the dist directory
$PYTHON -m pip install --no-deps --no-build-isolation --prefix=$PREFIX ${WHL_DIR}/*.whl

echo "PREFIX:"
echo "${PREFIX}"
# $PYTHON -c "import cuik_molmaker; print(cuik_molmaker.__file__)"
set +x