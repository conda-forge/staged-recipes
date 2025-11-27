#!/usr/bin/env bash
set -euo pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

cat <<'CODE' > hello.janet
(defn main [& args]
  (print "Hello from quickbin!"))
CODE

jpm quickbin hello.janet hello
[[ -x hello ]]
./hello | grep "Hello from quickbin!"
