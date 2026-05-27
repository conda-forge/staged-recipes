#!/usr/bin/env bash
# Install MongoDB Community Server binaries from the extracted upstream
# tarball into $PREFIX. No compilation; binary repackage.
# This script runs on Linux and macOS (both x86_64 and arm64).
set -euxo pipefail


if [ ! -x "./bin/mongod" ] || [ ! -x "./bin/mongos" ]; then
    echo "ERROR: expected ./bin/mongod and ./bin/mongos in the extracted tarball" >&2
    echo "Got:" >&2
    ls -la >&2
    exit 1
fi

# Binaries
mkdir -p "${PREFIX}/bin"
cp "./bin/mongod" "${PREFIX}/bin/"
cp "./bin/mongos" "${PREFIX}/bin/"
chmod +x "${PREFIX}/bin/mongod" "${PREFIX}/bin/mongos"

# License files and third-party notices
mkdir -p "${PREFIX}/share/mongodb-server-binary"
for f in LICENSE-Community.txt THIRD-PARTY-NOTICES MPL-2 README; do
    if [ -f "./${f}" ]; then
        cp "./${f}" "${PREFIX}/share/mongodb-server-binary/"
    fi
done

# Sanity check
"${PREFIX}/bin/mongod" --version
"${PREFIX}/bin/mongos" --version
