#!/usr/bin/env bash
set -euo pipefail

PROTO_ROOT="$SRC_DIR/proto"
OUT_DIR="$SRC_DIR/out"

# Collect all .proto files relative to the proto root.
PROTO_FILES=()
while IFS= read -r -d '' f; do
  PROTO_FILES+=("${f#"$PROTO_ROOT/"}")
done < <(find "$PROTO_ROOT" -name '*.proto' -print0)

# Generate Python protobuf stubs.
mkdir -p "$OUT_DIR"
protoc \
  --proto_path="$PROTO_ROOT" \
  --proto_path="$PREFIX/include" \
  --python_out="$OUT_DIR" \
  "${PROTO_FILES[@]}"

# Create __init__.py files for every package directory.
find "$OUT_DIR" -type d -print0 | while IFS= read -r -d '' dir; do
  touch "$dir/__init__.py"
done

# Build a minimal Python package from the generated stubs.
cat > "$SRC_DIR/pyproject.toml" << PYPROJECT
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"

[project]
name = "cel-spec-proto-python"
version = "$PKG_VERSION"
requires-python = ">=3.10"
dependencies = ["protobuf>=5"]

[tool.setuptools.packages.find]
where = ["out"]
PYPROJECT

"$PYTHON" -m pip install "$SRC_DIR" -vv --no-deps --no-build-isolation
