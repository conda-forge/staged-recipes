#!/usr/bin/env bash
set -eux

mkdir -p "${PREFIX}/lib/"
cp "${SRC_DIR}/build/dist/vnu.jar" "${PREFIX}/lib/"

mkdir -p "${PREFIX}/bin"

echo '#!/usr/bin/env bash'                       > "${PREFIX}/bin/vnu"
echo 'java -jar "'$PREFIX'/lib/vnu.jar" "$@"'   >> "${PREFIX}/bin/vnu"
chmod +x "${PREFIX}/bin/vnu"

cat "${PREFIX}/bin/vnu"
