#!/bin/sh
CONDA_CLONES="${CONDA_PREFIX}/share/julia/conda_clones"
mkdir -p "${CONDA_CLONES}"
cd "${CONDA_CLONES}"
git clone --depth=1 --branch="v1.3.0" https://github.com/JuliaInterop/VersionParsing.jl
source "${CONDA_PREFIX}/etc/conda/activate.d/kk_julia-conda-packaging_activate.sh"
julia -e "using VersionParsing"
