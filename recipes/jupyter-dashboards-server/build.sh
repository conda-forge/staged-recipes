#!/bin/bash

# Some dependencies postinstall scripts (phosphor-dragdrop:`npm dedupe`) causes some permission error on docker
npm install -g --ignore-scripts
