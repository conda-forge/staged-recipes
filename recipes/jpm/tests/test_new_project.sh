#!/usr/bin/env bash
set -euo pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

cat <<'EOF' > project.janet
(declare-project
  :name "sample-project"
  :version "0.1.0")

(rule "build/ok.txt" []
  (when (not (os/stat "build" :mode))
    (os/mkdir "build"))
  (spit "build/ok.txt" "ok"))

(task "build" ["build/ok.txt"])
EOF

jpm build
test -f build/ok.txt
grep -q "ok" build/ok.txt
