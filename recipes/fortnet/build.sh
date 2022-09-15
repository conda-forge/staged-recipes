#!/usr/bin/env bash
set -ex

if [ "${mpi}" != "nompi" ]; then
  MPI=ON
else
  MPI=OFF
fi

cmake_options=(
   ${CMAKE_ARGS}
   "-DLAPACK_LIBRARY='lapack;blas'"
   "-DWITH_SOCKETS=ON"
   "-DWITH_MPI=${MPI}"
   "-DBUILD_SHARED_LIBS=ON"
   "-GNinja"
   ${cmake_mpi_options[@]}
   ..
)

mkdir -p _build
pushd _build

FFLAGS="-fno-backtrace" cmake "${cmake_options[@]}"
ninja all install

popd


if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
  exit 0
fi

#
# Very quick test (< 10s) to check build sanity (checking most important components)
#

if [ "${mpi}" = "openmpi" ]; then
  export OMPI_MCA_plm=isolated
  export OMPI_MCA_btl_vader_single_copy_mechanism=none
  export OMPI_MCA_rmaps_base_oversubscribe=yes
fi

ctest_regexps=(
  'training/singlespecies/globalTargets/optimizer/steepestdesc$'
  'validation/singlespecies/globalTargets/optimizer/steepestdesc$'
  'prediction/singlespecies/globalTargets/optimizer/steepestdesc$'
)

pushd _build
for ctest_regexp in ${ctest_regexps[@]}; do
  ctest -R "${ctest_regexp}"
done
popd
