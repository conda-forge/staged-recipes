#!/bin/bash

# rebuild the package database after install
octave -q -W --eval "pkg rebuild -global"
