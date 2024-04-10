#!/usr/bin/env bash
set -ex

# Build the project (artifact in target/)
mvn package

# Install in Maven reposotory
mvn install

# Build standalone jar
mvn -Plocal -Dmaven.test.skip=true package

