set -eux
pip check
mkdir testsbproj
cd testsbproj
sb --init dgcode COMPACT
dgcode_newsimproject TriCorder
sb --tests
sbenv sb_core_extdeps --require NCrystal Geant4



