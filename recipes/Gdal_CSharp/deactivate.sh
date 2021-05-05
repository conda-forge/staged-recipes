if [[ -n ${CS_OLD_MONO_PATH} ]]; then
    export MONO_PATH=$CS_OLD_MONO_PATH
    unset CS_OLD_MONO_PATH
else
    unset MONO_PATH
fi