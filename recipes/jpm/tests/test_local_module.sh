#!/usr/bin/env bash
set -euo pipefail

: "${PREFIX:?}"
export JANET_PATH="${PREFIX}/lib/janet"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

mkdir -p mymod
cat <<'PROJECT' > mymod/project.janet
(declare-project
  :name "mymod"
  :description "local test module"
  :version "0.1.0")

(declare-source
  :prefix "mymod"
  :source ["src/init.janet"])
PROJECT

mkdir -p mymod/src
cat <<'CODE' > mymod/src/init.janet
(defn greet [] "hi from module")
CODE

pushd mymod >/dev/null
jpm install
popd >/dev/null

janet -e '(import mymod :as m) (assert (= "hi from module" (m/greet)))'
