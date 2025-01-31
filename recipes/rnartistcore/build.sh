#!/bin/bash
set -ex  # Fail on error and print each command

# Build the project using Maven
mvn clean package

# Create installation directory
mkdir -p "${PREFIX}/share/rnartistcore"

# Copy the built JAR file to the installation directory
cp target/rnartistcore-*-jar-with-dependencies.jar "${PREFIX}/share/rnartistcore/rnartistcore.jar"
