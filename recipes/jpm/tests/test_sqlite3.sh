#!/usr/bin/env bash
set -euo pipefail

: "${PREFIX:?}"
export JANET_PATH="${PREFIX}/lib/janet"
export JANET_SYSTEM_SQLITE=1
export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

git clone https://github.com/janet-lang/sqlite3.git
cd sqlite3

jpm install

janet -e '(import sqlite3 :as sql) (def db (sql/open "test.db")) (sql/close db)'
