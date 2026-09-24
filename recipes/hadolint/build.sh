#!/usr/bin/env bash
set -euxo pipefail

mkdir -p "${PREFIX}/bin"

for f in hadolint-*; do
	if [[ -f $f ]]; then
		install -m 755 "$f" "${PREFIX}/bin/hadolint"
		exit 0
	fi
done

echo "ERROR: hadolint binary not found"
exit 1
