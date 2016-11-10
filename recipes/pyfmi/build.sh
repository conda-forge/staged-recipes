#!/bin/sh

$PYTHON setup.py build --fmil-home=${PREFIX}
$PYTHON setup.py install --fmil-home=${PREFIX}
