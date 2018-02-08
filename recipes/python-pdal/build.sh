#!/bin/bash

set -ex

$PYTHON setup.py build
$PYTHON setup.py install
$PYTHON setup.py test
