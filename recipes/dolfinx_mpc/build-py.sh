set -eux

# https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

export CMAKE_ARGS="${CMAKE_ARGS} -DPython3_FIND_STRATEGY=LOCATION"
${PYTHON} -m pip install --no-build-isolation --no-deps -vv ./python
