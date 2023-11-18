# Path to telemac root dir
export HOMETEL=$CONDA_PREFIX/opentelemac
# Adding python scripts to PATH
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
### Python
# To force python to flush its output
export PATH=$HOMETEL/scripts/python3:$PATH
export PYTHONPATH=$HOMETEL/scripts/python3
export PYTHONPATH=$HOMETEL/builds/$USETELCFG/wrap_api/lib:$PYTHONPATH
export LD_LIBRARY_PATH=$HOMETEL/builds/$USETELCFG/wrap_api/lib:$HOMETEL/builds/$USETELCFG/lib:$CONDA_PREFIX/lib
export PYTHONUNBUFFERED='true'

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
