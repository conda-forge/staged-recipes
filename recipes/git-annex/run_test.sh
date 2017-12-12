#!/bin/sh

set -e -o pipefail -x

git annex version
git annex test
