#!/bin/sh
# lfric-env -- undo the activation contract (see activate.sh).
#
# Installed as $PREFIX/etc/conda/deactivate.d/000-lfric-env.sh.
#
# FILENAME PREFIX -- the `000-` matters, and is the mirror image of the `zzz-`
# on the activate script. conda sources deactivate.d/*.sh in sorted order too (not
# reverse order), and conda-forge's compiler scripts are named
# `deactivate-<pkg>_<subdir>.sh`. This must run BEFORE them: it restores CXX to
# the value the compiler activation had set, and only then may the compiler's own
# deactivate restore CXX to whatever the user had before conda. Reversing the two
# would leave conda's CXX behind after `conda deactivate`.

# Mirror of activate.sh's _lfric_env_save, and idempotent for the same reason: a
# MISSING marker means there is nothing of ours in the shell (never activated, or
# already restored), so leave the variable alone. Unsetting it unconditionally
# would destroy the caller's own value the second time `conda deactivate` ran.
_lfric_env_restore() {
    eval "if [ -z \"\${_LFRIC_ENV_HAD_$1+x}\" ]; then
              :
          elif [ \"\$_LFRIC_ENV_HAD_$1\" = 1 ]; then
              $1=\"\${_LFRIC_ENV_SAVED_$1}\"; export $1
              unset _LFRIC_ENV_HAD_$1 _LFRIC_ENV_SAVED_$1
          else
              unset $1 _LFRIC_ENV_HAD_$1 _LFRIC_ENV_SAVED_$1
          fi"
}

for _lfric_v in FC LDMPI CXX MPICH_CXX FPP LFRIC_TARGET_PLATFORM \
                FFLAGS LDFLAGS SHUMLIB_ROOT HDF5_USE_FILE_LOCKING \
                PYTHONDONTWRITEBYTECODE LFRIC_ENV_ACTIVE; do
    _lfric_env_restore "$_lfric_v"
done
unset _lfric_v

unset -f _lfric_env_restore
