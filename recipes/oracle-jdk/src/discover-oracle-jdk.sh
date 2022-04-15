#!/bin/bash -euo

# Discovery
# /usr/java/jdk1.8.0_321-amd64/bin/java is where the oracle rpm puts java.
WIP=0
for gx in /usr/java/jdk1.8.0_*; do
  BASE_NAME=$(basename -- "${gx}")
  BACK=${BASE_NAME##jdk1.8.0_}
  REVISION=${BACK%-*}
  if [ "$REVISION" -gt "$WIP" ]; then
    WIP=$REVISION
    export ORACLE_JDK_DIR="$gx"
  fi
done

