# Path to telemac root dir
export HOMETEL=$CONDA_PREFIX/opentelemac

# Backup original environment variables if not already done
if [[ -z "${OLD_PATH}" ]]; then
    export OLD_PATH="${PATH}"
fi
if [[ -z "${OLD_PYTHONPATH}" ]]; then
    export OLD_PYTHONPATH="${PYTHONPATH}"
fi
if [[ -z "${OLD_LD_LIBRARY_PATH}" ]]; then
    export OLD_LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"
fi

# Optional: Echo the variables to ensure they are correctly restored
echo "Stored PATH: ${OLD_PATH}"
echo "Stored PYTHONPATH: ${OLD_PYTHONPATH}"
echo "Stored LD_LIBRARY_PATH: ${OLD_LD_LIBRARY_PATH}"
# Configuration file
if [[ $(uname) == Linux ]]; then
   export SYSTELCFG=$HOMETEL/configs/systel.cfg
   # Name of the configuration to use
   export USETELCFG=gnu.dynamic
#OSX
elif [[ $(uname) == Darwin ]]; then
   export SYSTELCFG=$HOMETEL/configs/systel.cfg
   # Name of the configuration to use
   export USETELCFG=gfort-mpich
fi

# Adding python scripts and TELEMAC libs to PATH/LD_LIBRARY_PATH
export PATH=$HOMETEL/scripts/python3:$PATH
export PYTHONPATH=$HOMETEL/scripts/python3:$PYTHONPATH
export PYTHONPATH=$HOMETEL/builds/$USETELCFG/wrap_api/lib:$PYTHONPATH
export LD_LIBRARY_PATH=$HOMETEL/builds/$USETELCFG/wrap_api/lib:$HOMETEL/builds/$USETELCFG/lib:$LD_LIBRARY_PATH

# telemac-debug() {
#     if [[ "$1" == "on" ]]; then
#         export USETELCFG="gnu.dynamic.debug"
#         echo "Telemac debug mode ON"
#     elif [[ "$1" == "off" ]]; then
#         export USETELCFG="gnu.dynamic"
#         echo "Telemac debug mode OFF"
#     else
#         echo "Usage: telemac-debug [on|off]"
#     fi
# }
