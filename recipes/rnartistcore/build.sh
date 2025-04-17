#!/bin/bash
set -ex  # Fail on error and print each command

# Build the project using Maven
mvn clean package

# Generate a THIRD-PARTY license report
mvn org.codehaus.mojo:license-maven-plugin:3.0:aggregate-add-third-party

# Create installation directory
mkdir -p "${PREFIX}/share/rnartistcore"

# Copy the built JAR file to the installation directory
cp target/rnartistcore-*-jar-with-dependencies.jar "${PREFIX}/share/rnartistcore/rnartistcore.jar"

# Copy the third‑party license report
cp target/generated-sources/license/THIRD-PARTY.txt "${PREFIX}/share/rnartistcore/THIRD-PARTY.txt"
