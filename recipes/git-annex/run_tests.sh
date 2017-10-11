#!/bin/sh

set -e -o pipefail -x

git init
echo running git annex
git annex init
echo git annex init returned $?
