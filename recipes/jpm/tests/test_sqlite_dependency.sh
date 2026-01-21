#!/usr/bin/env bash
set -euo pipefail

: "${PREFIX:?}"
export JANET_PATH="${PREFIX}/lib/janet"
export JANET_SYSTEM_SQLITE=1
export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

cat <<'PROJECT' > project.janet
(declare-project
  :name "sqlite-dep-test"
  :version "0.1.0"
  :dependencies @["git::https://github.com/janet-lang/sqlite3.git"])
PROJECT

jpm deps

janet -e '(import sqlite3 :as sql) (def db (sql/open "dep.db")) (sql/close db)'

cat <<'HELLO' > hello.janet
(import sqlite3 :as sql)
(defn main [& args]
  (def db (sql/open "dep-quickbin.db"))
  (sql/close db)
  (print "sqlite quickbin ok"))
HELLO

jpm quickbin hello.janet hello
./hello | grep "sqlite quickbin ok"
