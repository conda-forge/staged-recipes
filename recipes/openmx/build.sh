#!/usr/bin/env bash
set -euo pipefail

export OMPI_CC="${CC}"
export OMPI_FC="${FC}"
export OMPI_F90="${FC}"

cd "${SRC_DIR}"

if [[ -x "${PREFIX}/bin/mpifort" ]]; then
  mpifc="${PREFIX}/bin/mpifort"
elif [[ -x "${PREFIX}/bin/mpif90" ]]; then
  mpifc="${PREFIX}/bin/mpif90"
else
  echo "No MPI Fortran compiler wrapper found in PREFIX" >&2
  exit 1
fi

if [[ -x "${PREFIX}/bin/mpicc" ]]; then
  mpicc="${PREFIX}/bin/mpicc"
else
  echo "No MPI C compiler wrapper found in PREFIX" >&2
  exit 1
fi

cp "${SRC_DIR}/patch4.0.1/Band_DFT_Dosout.c" source/Band_DFT_Dosout.c
cp "${SRC_DIR}/patch4.0.1/Mulliken_Charge.c" source/Mulliken_Charge.c
cp "${SRC_DIR}/patch4.0.1/GaAs.dat" work/GaAs.dat

data_path="${PREFIX}/share/openmx/DFT_DATA19"
elpa="${PWD}/source/elpa-2018.05.001"
stagebin="${PWD}/stage/bin"
: "${target_platform:?target_platform must be set by conda-build}"
mkdir -p "${stagebin}"

ccflags=("${mpicc}")
for flag in ${CFLAGS:-}; do
  ccflags+=("${flag}")
done
ccflags+=(
  -std=gnu17
  -Dnosse
  -fcommon
  -Wno-implicit-function-declaration
  -Wno-incompatible-pointer-types
  -I"${PREFIX}/include"
  -I"${elpa}"
)

fcflags=("${mpifc}")
for flag in ${FFLAGS:-${FCFLAGS:-}}; do
  fcflags+=("${flag}")
done
fcflags+=(
  -fallow-argument-mismatch
  -I"${elpa}"
)

libs=(
  -L"${PREFIX}/lib"
  -lscalapack
  -llapack
  -lblas
  -lfftw3
)

if [[ "${target_platform}" == osx-* ]]; then
  ccflags+=(-Xpreprocessor -fopenmp)
  ccflags+=(-Wno-incompatible-function-pointer-types)
  fcflags+=(-fopenmp)
  linkfc=("${mpifc}")
  for flag in ${FFLAGS:-${FCFLAGS:-}}; do
    linkfc+=("${flag}")
  done
  libs+=(-lomp)
else
  ccflags+=(-fopenmp)
  fcflags+=(-fopenmp)
  linkfc=("${fcflags[@]}")
fi

sed -i.bak "s|../DFT_DATA19|${data_path}|g" source/Input_std.c
sed -i.bak "s|DATA.PATH                     ./|DATA.PATH                     ${data_path}|g" source/cif2omx.c
sed -i.bak "s|inline void Spherical_Bessel2|static inline void Spherical_Bessel2|" source/Set_ProExpn_VNA.c
sed -i.bak $'s|\t$(CC) $(OBJS) $(LIB) -lm -o openmx|\t$(LINKFC) $(OBJS) $(LIB) -lm -o openmx|' source/makefile
sed -i.bak $'s|\tgcc |\t$(CC) |g' source/makefile

make -C source all \
  CC="${ccflags[*]}" \
  FC="${fcflags[*]}" \
  LINKFC="${linkfc[*]}" \
  LIB="${libs[*]}" \
  DESTDIR="${stagebin}"

staged_bins=("${stagebin}"/*)
if [[ ! -e "${staged_bins[0]}" ]]; then
  echo "No OpenMX binaries were staged" >&2
  exit 1
fi

mkdir -p "${PREFIX}/bin"
cp "${staged_bins[@]}" "${PREFIX}/bin/"

mkdir -p "${PREFIX}/share/openmx/examples"
cp -R DFT_DATA19 "${PREFIX}/share/openmx/"

while IFS= read -r -d '' dat; do
  if grep -q "DATA.PATH" "${dat}"; then
    sed -i.bak -E "s|^DATA\.PATH[[:space:]].*|DATA.PATH                     ${data_path}|" "${dat}"
    rm -f "${dat}.bak"
  fi
done < <(find work -name "*.dat" -type f -print0)

cp -R work "${PREFIX}/share/openmx/examples/"
