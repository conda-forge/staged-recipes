set -exou

mkdir -p "${PREFIX}/share/festival/dicts/cmu"
cp lib/dicts/cmu/*.scm "${PREFIX}/share/festival/dicts/cmu/"
cp lib/dicts/cmu/*.out "${PREFIX}/share/festival/dicts/cmu/"
