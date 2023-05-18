#!/bin/bash

set -ex

make

make install prefix=$PREFIX
