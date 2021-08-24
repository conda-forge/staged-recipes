export _CONDA_RESTORE_PATH=${PATH}

export _CONDA_RESTORE_MINTPY_HOME=${MINTPY_HOME}
if [[ -n "${MINTPY_HOME}" ]]; then
  # suppress MintPy import print statement
  export MINTPY_HOME=foobar
fi

_mintpy_home=$(python -c 'from pathlib import Path; import mintpy; print(Path(mintpy.__file__).parent)')
export PATH=${PATH}:${_mintpy_home}
export MINTPY_HOME=${_mintpy_home}
unset _mintpy_home