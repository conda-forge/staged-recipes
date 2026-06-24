#!/usr/bin/env bash

set -euxo pipefail

# Find the compiled native library from iroh-ffi-python installed as a HOST dep.
# HOST_PREFIX holds the target-arch artifacts (correct for cross-compilation).
if [[ "${target_platform}" == linux-* ]]; then
  IROH_LIB=$(find "${PREFIX}" -name "libiroh_ffi.so" | head -1)
  JNA_NAME="libiroh_ffi.so"
elif [[ "${target_platform}" == osx-* ]]; then
  IROH_LIB=$(find "${PREFIX}" -name "libiroh_ffi.dylib" | head -1)
  JNA_NAME="libiroh_ffi.dylib"
else
  IROH_LIB=$(find "${PREFIX}" -name "iroh_ffi.dll" | head -1)
  JNA_NAME="iroh_ffi.dll"
fi

# Generate Kotlin bindings against the compiled library
mkdir -p kotlin/lib/src/main/kotlin
uniffi-bindgen generate --language kotlin \
  --out-dir kotlin/lib/src/main/kotlin/ \
  --library "$IROH_LIB"

# Bundle the native library into Kotlin resources for JNA loading
mkdir -p kotlin/lib/src/main/resources
cp "$IROH_LIB" "kotlin/lib/src/main/resources/${JNA_NAME}"

# Build the Kotlin JAR
(cd kotlin && gradle build)

mkdir -p "$PREFIX/share/java/iroh"
JAR=$(find kotlin/lib/build/libs -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" | head -1)
cp "$JAR" "$PREFIX/share/java/iroh/iroh-${PKG_VERSION}.jar"
