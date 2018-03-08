set -e
set -x
mkdir -p "${PREFIX}/bin"
cp latexmk.pl "${PREFIX}/bin/latexmk"
mkdir -p "${PREFIX}/man/man1"
cp latexmk.1 "${PREFIX}/man/man1/latexmk.1"
