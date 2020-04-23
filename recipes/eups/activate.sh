# Bootstrap EUPS
#
# Derived from the stackvana-core recipe by Matt Becker (GitHub @beckermr)
# see: https://github.com/beckermr/stackvana-core/blob/master/recipe/stackvana_activate.sh
#


# clean/backup existing EUPS environment variable
for var in EUPS_PATH EUPS_SHELL SETUP_EUPS EUPS_DIR EUPS_PKGROOT; do
  if [[ "${!var}" ]]; then
    export BACKUP_${var}="${!var}"
  fi
  unset $var
done
export BACKUP_setup=`declare -f setup`
unset -f setup
if [[ -z "$BACKUP_setup" ]]; then
  unset BACKUP_setup
fi
export BACKUP_unsetup=`declare -f unsetup`
unset -f unsetup
if [[ -z "$BACKUP_unsetup" ]]; then
  unset BACKUP_unsetup
fi


# backup the python path in case eups is changing it
export BACKUP_PYTHONPATH=${PYTHONPATH}


# initializing eups
EUPS_DIR="${CONDA_PREFIX}/eups"
source "${EUPS_DIR}/bin/setups.sh"
export -f setup
export -f unsetup

