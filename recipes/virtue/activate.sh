#!/bin/bash

# Default , if not defined by the user
if [[ -z "${VIRTUE_SKILL_PREFIX}" ]]; then
  # shellcheck disable=SC2016
  echo 'Setting $VIRTUE_SKILL_PREFIX ='
  echo "  ${CONDA_PREFIX}/lib/skill"
  export VIRTUE_SKILL_PREFIX="${CONDA_PREFIX}/lib/skill"
fi


# Default cdsprj, can be overwritten by users
if ! command -v cdsprj &> /dev/null
then
    cdsprj ()
    {
         cd -- "/prj/$1" || exit
    }
fi

# Default viewprj, can be overwritten by users
# Should be setup by users to open a project read-only
if ! command -v viewprj &> /dev/null
then
    viewprj ()
    {
         cd -- "/prj/$1" || exit
    }
fi
