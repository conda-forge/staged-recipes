#!/usr/bin/env bash
set -euxo pipefail

# Run an isolated server. Its state directory holds the unix socket, so it has
# to live under a short path.
export XDG_STATE_HOME="$(mktemp -d /tmp/watchman.XXXXXX)"
trap 'watchman shutdown-server || true; rm -rf "${XDG_STATE_HOME}"' EXIT

watchman version | grep '"version": "'"${PKG_VERSION}"'"'

mkdir -p watched
echo '{}' > watched/.watchmanconfig
touch watched/hello.txt
watched="$(cd watched && pwd -P)"
# The CLI exits 0 even when a command fails, so check the response instead.
watchman watch "${watched}" | grep '"watch": "'"${watched}"'"'
watchman -- find "${watched}" '*.txt' | grep hello.txt

# A file created after the watch was established must be picked up.
touch watched/later.txt
watchman -- query "${watched}" '{"expression": ["suffix", "txt"], "fields": ["name"]}' | grep later.txt
