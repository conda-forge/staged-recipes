set -eux
pip list
pip check
#Verify pkg version also works on python level:
python -c 'from importlib.metadata import version as v;from os import environ as e;assert e["PKG_VERSION"]==v(e["PKG_NAME"])'
mkdir testsbproj
cd testsbproj
sb --init dgcode COMPACT
dgcode_newsimproject TriCorder
sb --tests
sbenv sb_core_extdeps --require NCrystal Geant4



