#!/usr/bin/env bash
set -exo pipefail

# This skill's license forbids retaining or distributing it outside Anthropic services.
rm -rf skills/productivity/powerpoint skills/index-cache

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

# setuptools does not preserve these data-file trees in the generated wheel.
mkdir -p "$PREFIX/skills" "$PREFIX/optional-skills"
cp -R skills/. "$PREFIX/skills/"
cp -R optional-skills/. "$PREFIX/optional-skills/"
