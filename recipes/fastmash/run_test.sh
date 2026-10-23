#!/bin/bash
# Check the installed version, arithmetic, notices and system Sort route.
set -euo pipefail
if [ "$#" -ne 1 ]; then
    echo 'usage: run_test.sh VERSION' >&2
    exit 1
fi
export LC_ALL=C
bin=$(dirname "$(command -v fastmash)")
test -x "$bin/fastmash-sort-supervisor"
for document in LICENSE-MIT LICENSE-APACHE THIRD-PARTY-LICENSES.md THIRDPARTY.yml; do
    test -s "$bin/../share/doc/fastmash/$document"
done
check() {
    local input="$1" expected="$2" actual
    shift 2
    actual=$(printf '%s' "$input" | "$bin/fastmash" "$@")
    if [ "$actual" != "$expected" ]; then
        printf 'expected %q, got %q\n' "$expected" "$actual" >&2
        exit 1
    fi
}
check '' "fastmash $1" --version
check $'1\n2\n3\n' $'6\t2' sum 1 mean 1
check $'b\t2\na\t1\na\t3\n' $'a\t4\nb\t2' -s -g 1 sum 2
check $'1\n2\n3\n' '1.8171205928321' geomean 1

# A grouped sum can use built-in sorting and conceal a broken supervisor.
# Require both exact output and the system route's trace from a paired operation.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
printf 'b\t2\t3\na\t1\t2\na\t3\t6\n' | \
    env -i PATH=/usr/bin:/bin LC_ALL=C FASTMASH_GROUPING=sort FASTMASH_SORT_TRACE=1 \
    "$bin/fastmash" -sg1 pcov 2:3 > "$work/actual" 2> "$work/diagnostic"
printf 'a\t2\nb\t0\n' > "$work/expected"
cmp "$work/expected" "$work/actual"
printf 'sort route: system sort\n' > "$work/expected"
cmp "$work/expected" "$work/diagnostic"
