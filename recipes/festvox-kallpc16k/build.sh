set -exou

mkdir -p "${PREFIX}/share/festival/voices/english/kal_diphone/festvox"
mkdir -p "${PREFIX}/share/festival/voices/english/kal_diphone/group"
cp lib/voices/english/kal_diphone/festvox/* "${PREFIX}/share/festival/voices/english/kal_diphone/festvox/"
cp lib/voices/english/kal_diphone/group/* "${PREFIX}/share/festival/voices/english/kal_diphone/group/"
