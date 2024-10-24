#!/usr/bin/env bash

# Unset the QEMU_LD_PREFIX environment variable
# and restore the previous value if it was set
unset QEMU_LD_PREFIX
if [[ -n "${_QEMU_LD_PREFIX_CONDA_BACKUP:-}" ]]; then
  export QEMU_LD_PREFIX=${_QEMU_LD_PREFIX_CONDA_BACKUP}
  unset _QEMU_LD_PREFIX_CONDA_BACKUP
fi
