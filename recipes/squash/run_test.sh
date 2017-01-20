#!/bin/bash
set -ex

COMPUTE_MD5="import hashlib, sys; print(hashlib.md5(sys.stdin.buffer.read()).hexdigest())"
TESTFILE=testdata.txt

DATA_MD5=$(cat $TESTFILE | python -c "$COMPUTE_MD5")

for CODEC in $(squash -L); do
  RESULT_MD5=$(cat $TESTFILE | squash -c $CODEC - - | squash -d -c $CODEC - - | python -c "$COMPUTE_MD5")
  [ "$DATA_MD5" = "$RESULT_MD5" ]
  echo "$CODEC OK"
done
