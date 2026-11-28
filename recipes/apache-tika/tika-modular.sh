#!/bin/bash
# Apache Tika modular launcher - uses individual package JARs
TIKA_HOME="$CONDA_PREFIX/share/java"

# Build classpath from individual packages
CP=""
for jar in "$TIKA_HOME"/*//*.jar; do
    if [ -n "$CP" ]; then
        CP="$CP:"
    fi
    CP="$CP$jar"
done

exec java -cp "$CP" org.apache.tika.cli.TikaCLI "$@"
