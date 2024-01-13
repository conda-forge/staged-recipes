set -eux
pip check
sb --help
python3 -c 'import _simple_build_system._cli'
unwrapped_simplebuild --help
mkdir testsbproj
cd testsbproj
sb --init core_val COMPACT
test -f simplebuild.cfg
cat simplebuild.cfg
sb -t
sbenv sb_core_extdeps --require-disabled NCrystal Numpy matplotlib Geant4 ZLib
eval "$(sb --env-setup)"
python3 -c 'import _simple_build_system.envsetup as sbe; sbe.verify_env_already_setup()'
sb_core_extdeps --require-disabled NCrystal Numpy matplotlib Geant4 ZLib
