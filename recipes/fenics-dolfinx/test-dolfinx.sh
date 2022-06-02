set -ex

$PYTHON -c "import dolfinx"
pip check

# disable clang availability check
if [[ "$target_platform" == "osx-64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

pytest -vx python/test
