set -euxo pipefail

export CPPTRAJ_LIBDIR="${CPPTRAJHOME}/lib"
export CPPTRAJ_HEADERDIR="{{ cpptraj_root }}/src"

echo "CPPTRAJHOME=${CPPTRAJHOME}"
echo "CPPTRAJ_LIBDIR=${CPPTRAJ_LIBDIR}"
echo "CPPTRAJ_HEADERDIR=${CPPTRAJ_HEADERDIR}"

{{ PYTHON }} -m pip install . -vv