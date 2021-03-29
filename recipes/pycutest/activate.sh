share_path=${CONDA_PREFIX}/share

export ARCHDEFS=${share_path}/archdefs
export SIFDECODE=${share_path}/sifdecode
export CUTEST=${share_path}/cutest
export MASTSIF=${share_path}/mastsif

export MYARCH="pc64.lnx.gfo"

# backup initial standard variables to restore them in deactivate.sh
export _CONDA_PYCUTEST_OLD_PATH=${PATH}
export _CONDA_PYCUTEST_OLD_MANPATH=${MANPATH}

export PATH=${SIFDECODE}/bin:${PATH}
export PATH=${CUTEST}/bin:${PATH}
export MANPATH=${SIFDECODE}/man:${MANPATH}
export MANPATH=${CUTEST}/man:${MANPATH}

