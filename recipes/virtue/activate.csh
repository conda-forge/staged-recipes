#!/bin/tcsh

if (! $?VIRTUE_SKILL_PREFIX) then       
  echo 'Setting $VIRTUE_SKILL_PREFIX ='
  echo "  ${CONDA_PREFIX}/lib/skill"
  setenv "VIRTUE_SKILL_PREFIX" "${CONDA_PREFIX}/lib/skill"
else
  if ("$var" == "")  then
      echo "variable is empty"
  else 
      echo "variable contains $var"
  endif
endif

# Default cdsprj, can be overwritten by users
if ( ! `where cdsprj` == "" ) then
    alias cdsprj cd !:1
endif

# Default cdsprj, can be overwritten by users
# Should be setup by users to open a project read-only
if ( `where viewprj` != "" ) then
    alias viewprj cd !:1
endif
