#!/bin/bash
# Apache Tika CLI wrapper script
# This script provides a convenient way to run Apache Tika from the command line

TIKA_JAR="${CONDA_PREFIX}/share/java/apache-tika/tika-app-@VERSION@.jar"

if [ ! -f "$TIKA_JAR" ]; then
    echo "Error: tika-app JAR not found at $TIKA_JAR" >&2
    exit 1
fi

exec java -jar "$TIKA_JAR" "$@"
