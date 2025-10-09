set -xeuo pipefail
echo "Checking environment"
cmake --version
python --version
rm -rf _skbuild

CMAKE_BUILD_PARALLEL_LEVEL=$(nproc) python -m pip install -vv .