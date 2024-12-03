#!/bin/bash

set -xeo pipefail

./gradlew

./gradlew generateLicenseReport

install -m 664 sbe-all/build/libs/sbe-all-${PKG_VERSION}.jar ${PREFIX}/lib
