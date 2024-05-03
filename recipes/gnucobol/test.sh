#!/usr/bin/env bash

set -euo pipefail

cat <<EOF > test.cbl
000001 IDENTIFICATION DIVISION.
000002 PROGRAM-ID. hello.
000003 PROCEDURE DIVISION.
000004 DISPLAY "Hello World!".
000005 STOP RUN.
EOF

cobc -x -o out test.cbl
./out | grep "Hello World!"
