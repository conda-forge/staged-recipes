set -exou

mkdir -p "${PREFIX}/share/festival/dicts"
cp lib/dicts/*.poslexR "${PREFIX}/share/festival/dicts/"
cp lib/dicts/*.ngrambin "${PREFIX}/share/festival/dicts/"
