#!/usr/bin/env bash
set -ex

$PYTHON -m pip install . -vv
npm pack jupyter-widget-datetime@${PKG_VERSION}
mkdir -p jupyter-widget-datetime/share/jupyter/lab/extensions/js
cp jupyter-widget-datetime-${PKG_VERSION}.tgz jupyter-widget-datetime/share/jupyter/lab/extensions/js
