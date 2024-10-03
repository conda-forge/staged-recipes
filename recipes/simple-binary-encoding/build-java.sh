#!/bin/bash

set -xeo pipefail

./gradlew

install -m 664 sbe-all/build/libs/sbe-all-${PKG_VERSION}.jar ${PREFIX}/lib
